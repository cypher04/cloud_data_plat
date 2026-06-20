# Traffic Flow

End-to-end description of how data and control messages move through the Cloud Data Platform. This document is the reference for understanding which network paths, identities, DNS zones, and firewall rules are exercised by each interaction with the platform.

---

## 1. Overview

The platform has three concurrent traffic planes:

| Plane | Direction | Examples |
|---|---|---|
| **Data plane** | Producer → Event Hub → Lake → Synapse compute | Event ingestion, Avro capture, Spark/SQL reads, transformed writes |
| **Control plane** | Operator → Azure ARM | Terraform applies, portal actions, ARM API calls |
| **Identity plane** | Service → Entra ID | Managed-identity token acquisition, RBAC checks |

All data-plane traffic between Azure services traverses **private endpoints** — either in the customer VNet or in Synapse's managed VNet. No data-plane traffic between the in-scope services leaves the Azure backbone.

---

## 2. Network Topology

### Virtual network

A single virtual network (`var.virtual_network_name`, address space `var.address_space`) hosts six subnets:

| Index | Subnet name | Variable key | Role |
|---|---|---|---|
| 0 | `cloud-subnet` | `web` | Reserved for web-facing workloads |
| 1 | `cloud-subnet-db` | `database` | Reserved for database workloads |
| 2 | `cloud-subnet-1` | `data-sub-1` | Reserved for analytics workloads |
| 3 | `cloud-subnet-2` | `data-sub-2` | Reserved for analytics workloads |
| 4 | `cloud-subnet-synapse` | `synapse-compute` | Hosts customer private endpoints to Synapse and the data lake |
| 5 | `cloud-subnet-hdinsight` | `hdinsight` | Hosts customer private endpoints for the ingestion path |

Subnets are referenced by **positional index** in dependent modules (`var.subnet_ids[4]`, `var.subnet_ids[5]`). The order defined in [modules/networking/outputs.tf](modules/networking/outputs.tf) is the contract.

### Two private endpoint estates

```
   ┌────────────────────────────┐         ┌────────────────────────────┐
   │   Customer VNet            │         │   Synapse Managed VNet     │
   │   (clouddata-vnet)         │         │   (managed by Synapse)     │
   │                            │         │                            │
   │   PE → Synapse Sql         │         │   Managed PE → Synapse     │
   │   PE → Synapse Dev         │         │      internal blob storage │
   │   PE → Synapse blob        │         │   Managed PE → Data Lake   │
   │   PE → Data Lake (dfs)     │         │      (dfs)                 │
   │   PE → EH path to Lake     │         │                            │
   └────────────────────────────┘         └────────────────────────────┘
```

- **Customer VNet PEs** serve in-VNet consumers (engineers via jump box, Data Factory SHIR, on-prem traffic via VPN, etc.).
- **Synapse managed PEs** serve the workspace's own Spark and SQL compute, which lives inside Synapse's managed VNet.

---

## 3. Ingestion Path — Producer to Event Hub

```
External producer
       │
       │  AMQP / Kafka protocol over TCP/5671 or TCP/9093
       │  Authentication: SAS or AAD via service principal / MI
       ▼
Event Hub Namespace (Standard tier)
  └── Event Hub
        partition count: 2
        retention:       1 day
        capture:         enabled (Avro)
```

- The Event Hub namespace is provisioned in the [eventhub](modules/eventhub/) module as `eventhubnamespace<random>` (SKU `Standard`, capacity `1`, system-assigned managed identity).
- The hub `eventhub<random>` accepts events on two partitions with a one-day retention window.
- Producers connect to `<namespace>.servicebus.windows.net:5671` (AMQP) or `:9093` (Kafka protocol surface). The Standard SKU supports both.
- The Event Hubs namespace currently exposes its public endpoint. To enforce VNet-only ingestion, a private endpoint and `network_rulesets` block targeting the namespace would be added.

---

## 4. Capture Path — Event Hub to Data Lake

Once events arrive in the hub, Event Hub capture writes them as Avro files on a sliding interval (the default — every 5 minutes or 300 MB, whichever comes first).

```
Event Hub  ──capture (Avro)──▶  Data Lake Gen2
                                cloudfilesystem
                                container: hdinsightcontainer
                                path: {namespace}/{eventhub}/{partition}/{yyyy}/{MM}/{dd}/{HH}/{mm}/{ss}
```

Capture configuration (defined in [modules/eventhub/main.tf](modules/eventhub/main.tf)):

| Field | Value |
|---|---|
| `enabled` | `true` |
| `encoding` | `Avro` |
| `storage_account_id` | Data lake storage account (`var.datalake_storage_account_id`) |
| `blob_container_name` | `hdinsightcontainer` |
| `archive_name_format` | `{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}` |

**Identity for capture writes:** the Event Hub namespace's system-assigned MI is granted `Storage Blob Data Contributor` on both:
- the Event Hub backing storage account (`hdinsight<random>`)
- the data lake storage account (`cloudstoragedl<random>`)

Capture traffic from the Event Hub service to the storage account flows over the Azure backbone using AAD-authenticated calls from the namespace's managed identity.

---

## 5. Analytics Path — Synapse to Data Lake

Synapse Spark and dedicated SQL pool jobs read from and write to the data lake.

```
Synapse compute (inside Synapse managed VNet)
       │
       │  abfss://cloudfilesystem@cloudstoragedl<random>.dfs.core.windows.net/...
       │  AAD token from Synapse system MI
       ▼
Synapse-managed Private Endpoint
       │
       │  privatelink.dfs.core.windows.net (resolved inside managed VNet)
       ▼
Data Lake Gen2 dfs endpoint
       │
       ▼
raw / processed / curated containers
```

- The Synapse workspace is created with `managed_virtual_network_enabled = true`, so all Spark and SQL pool egress flows through Synapse's managed VNet.
- A managed private endpoint targets the data lake storage account with `subresource_name = "dfs"` ([modules/synapse/main.tf:119-126](modules/synapse/main.tf#L119-L126)). DNS resolution inside the managed VNet returns the PE's private IP.
- The Synapse workspace's system-assigned MI holds `Storage Blob Data Contributor` on the data lake account, granting all read/write operations on `raw`, `processed`, and `curated`.
- A second managed private endpoint targets the Synapse-internal blob account (`subresource_name = "blob"`) for workspace-internal storage operations.

The dedicated SQL pool's `COPY INTO` from external storage uses the **same managed PE** — the pool runs inside the managed VNet and reaches the lake at `abfss://...`.

`data_exfiltration_protection_enabled = true` is set on the workspace. This restricts which storage tenants Synapse can reach to those in the workspace's tenant only.

---

## 6. Studio and SQL Client Path — Customer VNet to Synapse

```
Engineer / SQL client (in customer VNet, on-prem via VPN, or via public IP)
       │
       │  HTTPS / TDS
       ▼
azurerm_synapse_firewall_rule  (gateway check, IP allow-list)
       │
       ▼
Customer PE in subnet[4] (synapse-compute)
       │
       │  Resolved via the corresponding private DNS zone
       ▼
Synapse workspace sub-service
  ├── Sql        ─▶ dedicated SQL pool
  ├── dev        ─▶ Synapse Studio control APIs
  └── blob       ─▶ workspace-internal storage
```

### Customer private endpoints

Created by the [private_endpoint](modules/private_endpoint/main.tf) module, all in `subnet_ids[4]` (`synapse-compute`):

| Resource | `subresource_names` | Private DNS zone |
|---|---|---|
| `synapse_sql_pool_private_endpoint` | `Sql` | `privatelink.sql.azuresynapse.net` |
| `synapse_dev_private_endpoint` | `dev` | `privatelink.dev.azuresynapse.net` |
| `synapse_storage_account_private_endpoint` | `blob` | `privatelink.blob.core.windows.net` |
| `synapse_datalake_gen2_private_endpoint` | `dfs` | `privatelink.dfs.core.windows.net` |

Each PE is paired with an `azurerm_private_dns_zone` and `azurerm_private_dns_zone_virtual_network_link` so name resolution inside the VNet returns the PE's private IP for the public hostname.

### Firewall rules

The Synapse workspace's IP firewall ([modules/synapse/main.tf:80-92](modules/synapse/main.tf#L80-L92)) carries two rules:

| Rule | Range | Source |
|---|---|---|
| `AllowTerraformRunner` | runner's public IP / 32 | Discovered at plan time via `https://api.ipify.org` |
| `AllowAllWindowsAzureIps` | `0.0.0.0` / `0.0.0.0` | Azure-internal services flag |

A client request to Synapse's `Sql` or `Dev` endpoint that does not match either rule (and does not arrive via a private endpoint) is rejected at the gateway.

---

## 7. Ingestion-Path Private Endpoint (subnet 5)

An additional customer PE is provisioned in `subnet_ids[5]` (`hdinsight`) for in-VNet consumers of the ingestion path:

```
In-VNet consumer (subnet 5)
       │
       ▼
PE: eventhub-datalake-gen2-private-endpoint
       │
       │  Resolved via private DNS zone
       ▼
Data Lake storage account, dfs subresource
```

Defined in [modules/private_endpoint/main.tf:168-192](modules/private_endpoint/main.tf#L168-L192). This is distinct from the Synapse managed PE — it serves customer-VNet consumers (e.g., a SHIR, jump box, or ingestion tool) that need the same private path Synapse uses internally.

---

## 8. Secret Access Path — Synapse to Key Vault

Secrets (GitHub connector configuration today, additional credentials in future) live in Key Vault and are consumed in two distinct moments:

### At plan time (Terraform)

```
Terraform runner (data.azurerm_client_config.current)
       │
       │  Key Vault Administrator role
       ▼
Key Vault data-plane endpoint
       │
       ▼
data "azurerm_key_vault_secret" "github" [for_each]
       │
       │  Resolved values inlined into the github_repo block of azurerm_synapse_workspace
       ▼
Synapse workspace configuration
```

The runner's RBAC role is granted in [modules/keyvault/main.tf:140-148](modules/keyvault/main.tf#L140-L148), with a 30-second `time_sleep` to allow Entra ID role propagation before the secrets are read.

### At runtime (Synapse workspace)

```
Synapse workspace MI
       │
       │  Key Vault Secrets User role
       ▼
Key Vault data-plane endpoint
       │
       ▼
Linked services that reference Key Vault secrets (authored in Studio)
```

The Synapse system MI is granted `Key Vault Secrets User` ([modules/synapse/main.tf:112-116](modules/synapse/main.tf#L112-L116)), enabling pipeline linked services to dereference KV secrets at execution time without static credentials.

Key Vault itself runs in RBAC mode (`rbac_authorization_enabled = true`); legacy access policies are absent.

---

## 9. DNS Resolution Summary

| Service hostname | Private DNS zone | Resolved by |
|---|---|---|
| `<workspace>.sql.azuresynapse.net` | `privatelink.sql.azuresynapse.net` | Customer VNet (link in `private_endpoint` module) |
| `<workspace>.dev.azuresynapse.net` | `privatelink.dev.azuresynapse.net` | Customer VNet |
| `<workspace>.blob.core.windows.net` (internal) | `privatelink.blob.core.windows.net` | Customer VNet |
| `<datalake>.dfs.core.windows.net` | `privatelink.dfs.core.windows.net` | Customer VNet |
| `<datalake>.dfs.core.windows.net` (from Synapse compute) | Managed by Synapse | Synapse managed VNet |
| `<eventhub-ns>.servicebus.windows.net` | Not yet wired (public) | Public DNS |

All customer-VNet private DNS zones are linked to the VNet via `azurerm_private_dns_zone_virtual_network_link`. The Synapse managed VNet uses its own internal DNS that Synapse maintains automatically for its managed PEs.

---

## 10. Identity and RBAC Matrix

| Principal | Role | Scope | Purpose |
|---|---|---|---|
| Terraform runner (`data.azurerm_client_config.current`) | `Key Vault Administrator` | Key Vault | Write secrets, manage vault during apply |
| Synapse workspace system MI | `Storage Blob Data Contributor` | Data lake storage account | Read/write on `raw`, `processed`, `curated` |
| Synapse workspace system MI | `Key Vault Secrets User` | Key Vault | Read secrets at runtime via linked services |
| Event Hub namespace system MI | `Storage Blob Data Contributor` | Event Hub backing storage account | Write captured Avro files |
| Event Hub namespace system MI | `Storage Blob Data Contributor` | Data lake storage account | Write captured Avro files |

All managed identities are system-assigned and created with the parent resource (workspace or namespace), eliminating identity-lifecycle drift from the resource lifecycle.

---

## 11. End-to-End Sequence

A single ingestion event from producer to query result traverses the following hops:

```
1. Producer  ─AMQP/Kafka─▶  Event Hub Namespace (public endpoint, SAS or AAD auth)
2. Event Hub ─capture──▶    Data Lake account (AAD-auth via EH namespace MI)
                            Path: hdinsightcontainer/<ns>/<eh>/<part>/<yyyy>/<MM>/<dd>/<HH>/<mm>/<ss>
3. Synapse Spark/SQL  ──▶   Managed PE in Synapse managed VNet
                            ──▶ Data Lake dfs endpoint
                            ──▶ Reads raw → transforms → writes processed/curated
4. SQL client ─TDS────▶    Customer PE in subnet[4]
                            ──▶ Synapse Sql endpoint
                            ──▶ Dedicated SQL pool returns query result
```

---

## 12. Operational Notes

- Subnet positional indexing (`var.subnet_ids[4]`, `[5]`) is the current contract. Reordering the list in `modules/networking/outputs.tf` would silently move private endpoints to the wrong subnet.
- The Synapse firewall rule for the Terraform runner is **re-resolved on every apply** via `data "http"`. CI runners with rotating IPs will accumulate rules unless cleaned up.
- Synapse's managed VNet is opaque to operators — its internal DNS and PE state are managed by the service. Visibility is limited to the Synapse Studio "Manage" pane.
- Event Hub capture is **billed per throughput unit**, irrespective of whether messages are produced. Idle capture still incurs the TU cost.
- The data lake's `dfs` private DNS zone is shared between two PEs (customer-VNet via `private_endpoint` module, Synapse managed). Both resolve `<account>.dfs.core.windows.net` to a private IP appropriate to their network.

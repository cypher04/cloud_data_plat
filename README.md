# Cloud Data Platform

A production-oriented Azure data platform implemented in Terraform. The platform provisions a complete streaming analytics stack — ingest, lake storage, transformation, and serving — running inside a customer-managed virtual network with private connectivity to every data-plane endpoint.

---

## Overview

The platform delivers an end-to-end **Event Hubs → Data Lake → Synapse Analytics** pipeline on Azure:

- **Event Hubs** for high-throughput event ingestion, with automatic Avro capture to long-term storage.
- **Azure Data Lake Storage Gen2** as the unified analytical store, organised into raw, processed, and curated zones.
- **Azure Synapse Analytics** for SQL-based serving, Spark transformation, and pipeline orchestration, integrated with GitHub for version-controlled workspace artifacts.
- **Azure Key Vault** as the single source of truth for secrets and connector configuration.
- **Azure Log Analytics** as the platform's telemetry workspace.

All compute and storage endpoints are reachable exclusively via private endpoints inside the customer VNet or via Synapse's managed VNet. No service exposes a public data-plane endpoint by default.

---

## Architecture

```
                    ┌──────────────────────────┐
                    │   Event Hubs Namespace   │
                    │   (Standard, system MI)  │
                    │   └── Event Hub          │
                    │       Avro capture       │
                    └────────────┬─────────────┘
                                 │  managed capture
                                 ▼
                    ┌──────────────────────────┐
                    │   Data Lake Gen2 (HNS)   │
                    │   ├── raw                │
                    │   ├── processed          │
                    │   └── curated            │
                    └────────────┬─────────────┘
                                 │  private endpoint (dfs)
                                 ▼
                    ┌──────────────────────────┐
                    │   Synapse Workspace      │
                    │   ├── Dedicated SQL pool │
                    │   ├── Managed VNet + DEP │
                    │   └── Git-integrated     │
                    └──────────────────────────┘

    Supporting services
    ─────────────────────────────────────────────────────────────
    Key Vault (RBAC)              Log Analytics
    Virtual Network + Subnets     Private Endpoints + DNS Zones
    Managed Identities            Role-Based Access Control
```

---

## Repository Structure

```
cloud_data_plat/
├── backend/                  Bootstrap: remote-state storage backend
├── env/
│   ├── dev/                  Active development environment
│   ├── stage/                Pre-production environment
│   └── prod/                 Production environment
└── modules/
    ├── networking/           Virtual network and subnet topology
    ├── data-lake/            ADLS Gen2 account, filesystem, zoned containers
    ├── synapse/              Workspace, SQL pool, identity, Git integration
    ├── eventhub/             Event Hubs namespace and Avro capture pipeline
    ├── keyvault/             Secret store and access policies
    ├── private_endpoint/     Private endpoints and DNS zones
    ├── monitoring/           Log Analytics workspace
    └── data-factory/         Reserved for future orchestration extensions
```

---

## Modules

| Module | Responsibility |
|---|---|
| `networking` | Provisions the virtual network and six role-keyed subnets (`web`, `database`, `data-sub-1`, `data-sub-2`, `synapse-compute`, `hdinsight`). |
| `data-lake` | ADLS Gen2 storage account with hierarchical namespace, primary filesystem, and zoned containers (`raw`, `processed`, `curated`). |
| `synapse` | Synapse workspace with managed VNet and data-exfiltration protection enabled, dedicated SQL pool, system-assigned identity, GitHub repo integration, IP firewall rules, and managed private endpoints to the data lake and internal storage. |
| `eventhub` | Event Hubs namespace and event hub with managed Avro capture to the data lake. Provisions backing storage and role assignments for the namespace's managed identity. |
| `keyvault` | RBAC-enabled Key Vault holding GitHub connector secrets and other platform credentials. |
| `private_endpoint` | Customer-VNet private endpoints for Synapse (`Sql`, `Dev`, internal blob), the data lake (`dfs`), and the Event Hub ingestion path, with matching private DNS zones and VNet links. |
| `monitoring` | Log Analytics workspace for diagnostic ingestion. |
| `data-factory` | Reserved for future Data Factory orchestration extensions. |

---

## Prerequisites

- Terraform `>= 1.5`
- Azure CLI, authenticated against the target subscription (`az login`)
- A deployment identity with the following roles:

| Role | Scope | Purpose |
|---|---|---|
| `Contributor` | Subscription or resource group | Control-plane resource creation |
| `User Access Administrator` | Subscription or resource group | Role assignments to module-created identities |
| `Storage Blob Data Owner` | Data lake storage account | Data-plane filesystem and ACL operations |
| `Key Vault Secrets Officer` | Key Vault | Secret create / update operations |

- Outbound internet access from the deployment host — the Synapse module discovers the runner's public IP at plan time to seed the workspace firewall.

---

## Deployment

Deployment is a two-stage process: bootstrap the remote-state backend once per subscription, then apply each environment.

### 1. Bootstrap remote state

```bash
cd backend
terraform init
terraform apply
```

This provisions the storage account, container, and resource group that hold Terraform state for all subsequent environments.

### 2. Deploy an environment

```bash
cd env/dev
terraform init
terraform plan
terraform apply
```

Subsequent applies in the same environment require no additional setup. Stage and production environments follow the same pattern once their composition files are populated.

---

## Configuration

Environment-specific values are supplied through a `terraform.tfvars` file (gitignored). The required variables are:

```hcl
# Subscription and location
subscription_id      = "00000000-0000-0000-0000-000000000000"
resource_group_name  = "clouddata"
location             = "westeurope"

# Network topology
virtual_network_name = "clouddata-vnet"
address_space        = ["10.0.0.0/16"]
subnet_prefixes = {
  web             = "10.0.1.0/24"
  database        = "10.0.2.0/24"
  data-sub-1      = "10.0.3.0/24"
  data-sub-2      = "10.0.4.0/24"
  synapse-compute = "10.0.5.0/24"
  hdinsight       = "10.0.6.0/24"
}

# Synapse SQL administrator credentials
admin_username = "synapseadmin"
admin_password = "..."

# Synapse Git integration (stored as Key Vault secrets, read at plan time)
github_account_name = "..."
github_repo_name    = "..."
github_repo_branch  = "main"
github_repo_url     = "https://github.com/..."
```

Sensitive values are marked `sensitive = true` at the variable level and are never written to outputs.

---

## Networking

The platform's network topology is built around a single virtual network with six role-keyed subnets defined via the `subnet_prefixes` variable.

| Subnet | Purpose |
|---|---|
| `web` | Reserved for web-facing workloads |
| `database` | Reserved for database workloads |
| `data-sub-1`, `data-sub-2` | Reserved for analytics workloads |
| `synapse-compute` | Hosts customer private endpoints to Synapse and the data lake |
| `hdinsight` | Hosts customer private endpoints for the ingestion path |

Two classes of private connectivity are in use:

- **Customer private endpoints** — provisioned in the customer VNet to expose Synapse sub-services (`Sql`, `Dev`), the data lake (`dfs`), and the ingestion path to in-VNet consumers.
- **Synapse-managed private endpoints** — provisioned in Synapse's managed VNet, allowing Synapse compute to reach the data lake and internal storage without traversing the public internet.

The Synapse workspace runs with `managed_virtual_network_enabled = true` and `data_exfiltration_protection_enabled = true`. Workspace firewall rules permit the Terraform runner's public IP and Azure-internal services.

---

## Identity and Access

The platform uses a clear separation of responsibilities between the deployment identity and runtime identities:

| Principal | Role | Scope |
|---|---|---|
| Terraform runner | `Key Vault Secrets Officer` | Key Vault |
| Synapse workspace MI | `Storage Blob Data Contributor` | Data lake storage account |
| Synapse workspace MI | `Key Vault Secrets User` | Key Vault |
| Event Hubs namespace MI | `Storage Blob Data Contributor` | Capture-target storage accounts |

Secrets are written into Key Vault by the Terraform runner during apply, then consumed by the Synapse module via `data "azurerm_key_vault_secret"` at plan time. Runtime services (Synapse pipelines, Event Hubs capture) access Key Vault and storage through their managed identities, never through static credentials.

---

## Synapse Git Integration

The Synapse workspace is connected to a GitHub repository via the `github_repo` block on the workspace resource. Pipelines, notebooks, datasets, and linked services authored in Synapse Studio are committed as JSON artifacts to the configured branch, enabling code review, version control, and CI/CD-driven promotion to higher environments.

Connector parameters (repository URL, account, name, and branch) are stored as Key Vault secrets and read by Terraform at plan time, keeping repository configuration out of source control.

---

## State Management

Terraform state is stored remotely in Azure Blob Storage, provisioned by the `backend/` module:

| Property | Value |
|---|---|
| Resource group | `clouddatadev-rg` |
| Storage account | `clouddatastatedev` |
| Container | `tfstate` |
| State key | `terraform.tfstate` |

State files are encrypted at rest, versioned via blob versioning, and access-controlled via RBAC on the storage account.

---

## Environments

| Environment | Status |
|---|---|
| `dev` | Active |
| `stage` | Reserved |
| `prod` | Reserved |

Each environment is an isolated Terraform root module under `env/`, with its own state file and variable set. New environments are added by replicating the `env/dev` structure and supplying environment-specific values.

---

## Providers

| Provider | Version |
|---|---|
| `hashicorp/azurerm` | `4.73.0` |
| `hashicorp/random` | `3.5.1` |
| `hashicorp/time` | `0.14.0` |
| `hashicorp/http` | `3.4.0` |

---

## Conventions

- **Provisioning** is owned by this repository. Workspace artifacts (Synapse pipelines, notebooks, linked services) are owned by the Synapse-connected Git repository.
- Globally-unique resource names are suffixed with a `random_string` to ensure idempotency across environments.
- All sensitive variables are declared with `sensitive = true`.
- Secret values are never committed; `.tfvars` files are gitignored.
- Module inputs use explicit, named arguments — no positional or implicit defaults across module boundaries.

---

## License

Proprietary. All rights reserved.

# Terraform Configuration & Essential CLI Commands — Revision Guide

This guide breaks down the `terraform` configuration block, explains version constraints and every declared provider, and covers the core Terraform CLI workflow commands for quick revision.

---

## 1. Original Configuration Reference

```hcl
terraform {
  required_version = "~> 1.16.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.73.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.3"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.5.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 4.7.0"
    }
    shell = {
      source  = "scottwinkler/shell"
      version = "~> 1.7.10"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.0"
    }
  }
}
```

---

## 2. Structural Breakdown

### `terraform { ... }` Block
* **Purpose:** Defines global settings for Terraform itself, such as the required Terraform CLI version, required provider plugins, and backend state storage configuration.
* **Rule:** Only constant values can be used inside the `terraform` block; variables and resource attributes are not allowed here.

### `required_version = "~> 1.16.0"`
* **Purpose:** Enforces which version of the Terraform CLI binary is allowed to run this configuration. If a team member or CI/CD runner uses an incompatible version, Terraform immediately halts with an error to prevent state file corruption.

### Understanding the Pessimistic Constraint Operator (`~>`)
The `~>` (twiddle-wakka) operator allows **only the rightmost version component to increment** while keeping higher-level components locked:

| Constraint | Allowed Versions | Disallowed Versions | Meaning |
| :--- | :--- | :--- | :--- |
| `~> 1.16.0` | `1.16.0`, `1.16.1`, `1.16.9` | `1.17.0`, `2.0.0`, `1.15.9` | Locks Major (`1`) and Minor (`16`); allows Patch updates (`>= 1.16.0, < 1.17.0`). |
| `~> 6.73.0` | `6.73.0`, `6.73.4` | `6.74.0`, `7.0.0` | Locks `6.73.x`; allows only patch-level bug fixes (`>= 6.73.0, < 6.74.0`). |
| `~> 1.7.10` | `1.7.10`, `1.7.15` | `1.8.0`, `2.0.0` | Locks `1.7.x`; allows patch versions `10` and above (`>= 1.7.10, < 1.8.0`). |

---

## 3. `required_providers` Breakdown

Each entry inside `required_providers` maps a **local name** (e.g., `aws`, `docker`) to a registry **source** (`namespace/type`) and a **version** constraint.

| Local Name | Registry Source | Version Constraint | Maintainer Type | Primary Purpose & Common Use Cases |
| :--- | :--- | :--- | :--- | :--- |
| **`aws`** | `hashicorp/aws` | `~> 6.73.0` | Official (HashiCorp) | Manages Amazon Web Services infrastructure (EC2, S3, VPC, IAM, EKS, RDS, Lambda). |
| **`random`** | `hashicorp/random` | `~> 3.4.3` | Official (HashiCorp) | Generates deterministic random values stored in state (`random_password`, `random_id`, `random_string`, `random_pet`) to ensure unique resource names and secrets. |
| **`kubernetes`** | `hashicorp/kubernetes` | `~> 3.5.0` | Official (HashiCorp) | Manages Kubernetes cluster resources natively (`kubernetes_deployment`, `kubernetes_service`, `kubernetes_namespace`, `kubernetes_config_map`, `kubernetes_secret`). |
| **`docker`** | `kreuzwerker/docker` | `~> 4.7.0` | Community / Partner | Interacts with the Docker daemon to build/pull images (`docker_image`), run containers (`docker_container`), and manage Docker networks/volumes. |
| **`shell`** | `scottwinkler/shell` | `~> 1.7.10` | Community | Wraps arbitrary shell scripts/commands into full Terraform CRUD lifecycle resources (`shell_script`) with state tracking, unlike `local-exec` provisioners. |
| **`local`** | `hashicorp/local` | `~> 2.5.0` | Official (HashiCorp) | Manages local filesystem resources on the machine running Terraform (`local_file`, `local_sensitive_file`, `local_file` data source) such as generating inventory or config files. |
| **`null`** | `hashicorp/null` | `~> 3.2.0` | Official (HashiCorp) | Provides `null_resource` and `null_data_source` to run provisioners or trigger custom actions via `triggers` when no real infrastructure object needs to be created. |

> **Revision Tip on Provider Sources:**  
> Sources follow the format `[HOSTNAME/]NAMESPACE/TYPE`. When the hostname is omitted, Terraform defaults to the public Terraform Registry (`registry.terraform.io`).

---

## 4. Core Terraform CLI Workflow & Commands

The standard Terraform lifecycle follows this sequence:  
**Write (`fmt` / `validate`) $ightarrow$ Initialize (`init`) $ightarrow$ Preview (`plan`) $ightarrow$ Provision (`apply`) $ightarrow$ Tear Down (`destroy`)**

### 1. `terraform fmt` (Format)
* **What it does:** Rewrites Terraform configuration files (`.tf` and `.tfvars`) into canonical HashiCorp Configuration Language (HCL) formatting and style (aligns `=` signs, standardizes indentation to 2 spaces).
* **Key Flags:**
  * `terraform fmt -recursive` — Formats files in the current directory and all subdirectories.
  * `terraform fmt -check` — Checks if files are properly formatted without modifying them (useful in CI/CD pipelines; exits with non-zero code if unformatted).
  * `terraform fmt -diff` — Displays exact formatting changes made.

### 2. `terraform init` (Initialize)
* **What it does:** Prepares the working directory for use with Terraform. It must be the first command run after writing a new configuration or cloning an existing repository.
* **Key Actions Performed:**
  * Downloads and installs all provider plugins specified in `required_providers` into the hidden `.terraform/` directory.
  * Generates or updates the `.terraform.lock.hcl` dependency lock file to record exact provider versions and checksums.
  * Initializes the state backend (e.g., local state or remote S3/GCS backend) and downloads referenced modules.
* **Key Flags:**
  * `terraform init -upgrade` — Updates providers and modules to the newest versions allowed by your version constraints.
  * `terraform init -reconfigure` — Reconfigures backend settings while ignoring any saved configuration.

### 3. `terraform validate` (Validate)
* **What it does:** Checks whether the configuration is syntactically valid and internally consistent (verifies attribute names, argument types, and variable references) **without** accessing remote cloud APIs or state files.
* **Prerequisites:** Requires `terraform init` to have been run first so provider schemas are available locally.
* **Key Flags:**
  * `terraform validate -json` — Outputs validation results in machine-readable JSON format for CI pipelines.

### 4. `terraform plan` (Execution Plan)
* **What it does:** Performs a dry run by comparing your desired configuration against the current state file and real-world infrastructure, then prints an execution plan showing what Terraform will do.
* **Plan Symbols Legend:**
  * `+` **Create:** Resource does not exist yet and will be created.
  * `-` **Destroy:** Resource exists in state/cloud but was removed from code and will be deleted.
  * `~` **Update in-place:** Resource attributes will be modified without recreating the resource.
  * `-/+` **Destroy and then create (Replace):** An immutable attribute changed, forcing Terraform to destroy the old resource and create a new one.
* **Key Flags:**
  * `terraform plan -out=tfplan` — Saves the exact generated plan to a binary file so `terraform apply tfplan` executes only those reviewed changes.
  * `terraform plan -destroy` — Previews what would be destroyed without actually deleting anything.

### 5. `terraform apply` (Apply Changes)
* **What it does:** Executes the actions proposed in a Terraform plan to create, update, or delete real infrastructure and updates the `terraform.tfstate` file accordingly.
* **Key Flags:**
  * `terraform apply -auto-approve` — Skips the interactive `yes` confirmation prompt (commonly used in automated CI/CD workflows).
  * `terraform apply tfplan` — Applies a previously saved plan file without prompting for confirmation.
  * `terraform apply -target=aws_instance.example` — Applies changes only to a specific resource and its dependencies (use sparingly for troubleshooting).

### 6. `terraform destroy` (Destroy Infrastructure)
* **What it does:** Terminates and deletes all remote objects managed by the current Terraform state file in reverse dependency order. (Equivalent to running `terraform apply -destroy`).
* **Key Flags:**
  * `terraform destroy -auto-approve` — Destroys all managed resources without interactive confirmation.
  * `terraform destroy -target=resource_type.name` — Destroys only a single targeted resource.

---

## 5. Quick Revision Cheat Sheet

| Command | Requires `init`? | Touches Real Cloud / State? | Primary Goal |
| :--- | :---: | :---: | :--- |
| `terraform fmt` | No | No | Clean up code indentation and alignment. |
| `terraform init` | — | Backend only | Download providers, modules, and set up state backend. |
| `terraform validate` | Yes | No | Check HCL syntax, types, and internal references offline. |
| `terraform plan` | Yes | Reads state & cloud | Preview creates (`+`), updates (`~`), and destroys (`-`). |
| `terraform apply` | Yes | Modifies state & cloud | Provision or update real infrastructure. |
| `terraform destroy` | Yes | Modifies state & cloud | Tear down all Terraform-managed infrastructure. |

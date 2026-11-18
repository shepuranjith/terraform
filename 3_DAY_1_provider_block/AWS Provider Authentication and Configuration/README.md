# AWS Provider Authentication and Configuration

A comprehensive guide and reference repository demonstrating how the Terraform AWS Provider resolves credentials, handles authentication precedence, and configures advanced identity federation.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Project Structure](#project-structure)
3. [Credential Precedence Order](#credential-precedence-order)
4. [Standard Authentication Methods](#standard-authentication-methods)
   - [Provider Configuration Block](#1-provider-configuration-block)
   - [Environment Variables](#2-environment-variables)
   - [Shared Configuration and Credentials Files](#3-shared-configuration-and-credentials-files)
   - [Container Credentials](#4-container-credentials)
   - [Instance Profile Credentials](#5-instance-profile-credentials)
5. [Advanced Authentication Methods](#advanced-authentication-methods)
   - [IAM Role Chaining](#iam-role-chaining)
   - [Web Identity Federation & OpenID Connect (OIDC)](#web-identity-federation--openid-connect-oidc)
   - [Sourcing Credentials from an External Process](#sourcing-credentials-from-an-external-process)
6. [Usage Instructions](#usage-instructions)
7. [Inputs and Outputs](#inputs-and-outputs)

---

## Prerequisites

Ensure the following tools and versions are installed before running the configurations in this repository:

* **Terraform:** `~> 1.16.0`
* **AWS Provider (`hashicorp/aws`):** `~> 6.73.0`
* **AWS CLI:** v2.x (recommended for local SSO and profile management)

```hcl
terraform {
  required_version = "~> 1.16.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.73.0"
    }
  }
}
```

---

## Project Structure

```text
.
├── README.md
├── main.tf
├── providers.tf
├── variables.tf
└── outputs.tf
```

---

## Credential Precedence Order

Configuration for the AWS Provider can be derived from several sources, which are applied in the following order:

1. **Parameters in the provider configuration** (`access_key`, `secret_key`, `token`, `profile`)
2. **Environment variables** (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_PROFILE`, etc.)
3. **Shared credentials files** (`~/.aws/credentials`)
4. **Shared configuration files** (`~/.aws/config`)
5. **Container credentials** (Amazon ECS task IAM roles or EKS Pod Identity)
6. **Instance profile credentials and Region** (Amazon EC2 IMDSv2)

*This order matches the precedence used by the AWS CLI and the AWS SDK for Go v2.*

---

## Standard Authentication Methods

### 1. Provider Configuration Block

> **Warning:** Hard-coded credentials are not recommended in any Terraform configuration and risk secret leakage should this file ever be committed to a public version control system.

Credentials can be provided by adding `access_key`, `secret_key`, and optionally `token` to the `aws` provider block.

```hcl
provider "aws" {
  region     = "us-west-2"
  access_key = "my-access-key"
  secret_key = "my-secret-key"
}
```

Other authorization-related settings configurable in this block include:
* `profile`
* `shared_config_files`
* `shared_credentials_files`

---

### 2. Environment Variables

Credentials can be provided using the `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and optionally `AWS_SESSION_TOKEN` environment variables. The Region can be set using `AWS_REGION` or `AWS_DEFAULT_REGION`.

**Terraform Configuration (`providers.tf`):**
```hcl
provider "aws" {}
```

**Terminal Session:**
```bash
export AWS_ACCESS_KEY_ID="anaccesskey"
export AWS_SECRET_ACCESS_KEY="asecretkey"
export AWS_REGION="us-west-2"
terraform plan
```

Other environment variables related to authorization include:
* `AWS_PROFILE`
* `AWS_CONFIG_FILE`
* `AWS_SHARED_CREDENTIALS_FILE`

---

### 3. Shared Configuration and Credentials Files

The AWS Provider can source credentials and settings from shared configuration and credentials files.

* **Linux and macOS:** `$HOME/.aws/config` and `$HOME/.aws/credentials`
* **Windows:** `"%USERPROFILE%\.aws\config"` and `"%USERPROFILE%\.aws\credentials"`

If no named profile is specified, the `default` profile is used. Specify a named profile using the `profile` parameter or `AWS_PROFILE` environment variable. Custom file locations can be set via `shared_config_files` and `shared_credentials_files` or `AWS_CONFIG_FILE` and `AWS_SHARED_CREDENTIALS_FILE`.

```hcl
provider "aws" {
  shared_config_files      = ["/Users/tf_user/.aws/conf"]
  shared_credentials_files = ["/Users/tf_user/.aws/creds"]
  profile                  = "customprofile"
}
```

---

### 4. Container Credentials

When running Terraform inside Amazon ECS tasks or EKS pods, the provider automatically retrieves temporary credentials from the container metadata endpoint (`AWS_CONTAINER_CREDENTIALS_RELATIVE_URI` or `AWS_CONTAINER_CREDENTIALS_FULL_URI`).

```hcl
provider "aws" {
  region = "us-west-2"
}
```

---

### 5. Instance Profile Credentials

When running Terraform on an Amazon EC2 instance with an attached IAM Instance Profile, the provider automatically retrieves temporary credentials and region metadata via IMDSv2.

```hcl
provider "aws" {}
```

---

## Advanced Authentication Methods

### IAM Role Chaining

The AWS Provider supports assuming an IAM role either in the provider configuration block (`assume_role`) or in a named profile. When configured in the provider block, **IAM Role Chaining** is supported by specifying a list of `assume_role` blocks in sequential order.

```hcl
provider "aws" {
  region = "us-west-2"

  # Step 1: Base identity assumes the Jump/Bastion role
  assume_role {
    role_arn     = "arn:aws:iam::111122223333:role/JumpRole"
    session_name = "terraform-jump-session"
  }

  # Step 2: Jump role assumes the Target Workload role
  assume_role {
    role_arn     = "arn:aws:iam::444455556666:role/TargetDeploymentRole"
    session_name = "terraform-target-session"
    external_id  = "unique-external-id"
  }
}
```

---

### Web Identity Federation & OpenID Connect (OIDC)

The AWS Provider supports assuming an IAM role using Web Identity Federation and OpenID Connect (OIDC), commonly used in CI/CD pipelines (such as GitHub Actions or GitLab CI) and Amazon EKS IRSA.

#### Option A: Provider Configuration Block
```hcl
provider "aws" {
  region = "us-west-2"

  assume_role_with_web_identity {
    role_arn                = "arn:aws:iam::123456789012:role/GitHubActionsOIDCRole"
    session_name            = "github-actions-deploy"
    web_identity_token_file = "/var/run/secrets/eks.amazonaws.com/serviceaccount/token"
  }
}
```

#### Option B: Environment Variables
```bash
export AWS_ROLE_ARN="arn:aws:iam::123456789012:role/GitHubActionsOIDCRole"
export AWS_WEB_IDENTITY_TOKEN_FILE="/path/to/oidc/token"
export AWS_ROLE_SESSION_NAME="ci-cd-oidc-session"
export AWS_REGION="us-west-2"
terraform plan
```

---

### Sourcing Credentials from an External Process

When using a named profile in `~/.aws/config`, the AWS Provider can execute an external command or custom script that outputs temporary credentials in standard JSON format.

**`~/.aws/config`:**
```ini
[profile external-auth]
region = us-west-2
credential_process = /usr/local/bin/fetch-aws-creds --env prod
```

**`providers.tf`:**
```hcl
provider "aws" {
  profile = "external-auth"
}
```

---

## Usage Instructions

1. **Format configuration files:**
   ```bash
   terraform fmt -recursive
   ```
2. **Initialize the working directory and download the AWS provider:**
   ```bash
   terraform init
   ```
3. **Validate the configuration syntax:**
   ```bash
   terraform validate
   ```
4. **Preview infrastructure changes:**
   ```bash
   terraform plan
   ```
5. **Apply changes:**
   ```bash
   terraform apply
   ```
6. **Destroy managed infrastructure when finished:**
   ```bash
   terraform destroy
   ```

---

## Inputs and Outputs

### Inputs

| Name | Description | Type | Default | Required |
| :--- | :--- | :---: | :---: | :---: |
| `aws_region` | AWS region where resources will be provisioned | `string` | `"us-west-2"` | no |
| `aws_profile` | Named profile from shared AWS configuration files | `string` | `"default"` | no |
| `target_role_arn` | IAM Role ARN to assume for deployment | `string` | `null` | no |

### Outputs

| Name | Description |
| :--- | :--- |
| `caller_account_id` | AWS Account ID of the active authenticated identity |
| `caller_arn` | ARN of the active IAM user or assumed role session |

# Main block for configuring Terraform settings and behavior
terraform {
  # Restricts Terraform CLI to version 1.16.x (allows patch updates like 1.16.1, blocks 1.17.0+)
  required_version = "~> 1.16.0"

  # Specifies all external provider plugins required for this configuration
  required_providers {
    
    # Official AWS provider for managing Amazon Web Services cloud infrastructure
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.73.0" # Allows 6.73.x patch releases
    }

    # Utility provider for generating random strings, passwords, and IDs
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.3"
    }

    # Official Kubernetes provider for managing K8s pods, deployments, and services
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.5.0"
    }

    # Community Docker provider for pulling images and running local/remote containers
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 4.7.0"
    }

    # Community Shell provider for wrapping custom shell scripts as stateful resources
    shell = {
      source  = "scottwinkler/shell"
      version = "~> 1.7.10"
    }

    # Utility provider for creating and managing local files on your machine
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.0"
    }

    # Utility provider for triggering custom scripts or local-exec provisioners
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.0"
    }
  }
}


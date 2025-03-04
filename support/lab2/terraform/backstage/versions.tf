terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.111"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.6"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.13"
    }
  }
  required_version = ">= 1.1.0"
}

data "azurerm_client_config" "current" {}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = "${local.kubconfig_path}"
  }
}

provider "random" {}
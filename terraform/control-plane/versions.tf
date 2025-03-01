terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.111"
    }
    azapi = {
      source  = "Azure/azapi"
      version = ">= 1.4.0, < 2.0"
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
  environment = "usgovernment"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azapi" { 
}

resource "local_file" "kubeconfig" {
  content  = module.aks.kube_config_raw
  filename = "kubeconfig"
}

provider "kubernetes" {    
  config_path = local_file.kubeconfig.filename
}

provider "helm" {
  kubernetes {
    config_path = local_file.kubeconfig.filename
  }

}
provider "random" {}

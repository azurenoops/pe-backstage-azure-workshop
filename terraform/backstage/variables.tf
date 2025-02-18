variable "resource_group_name" {
  description = "Specifies the name of the resource group."
  default     = "backstage-rg"
  type        = string
}

variable "github_token" {
  description = "Specifies the GitHub token for the GitHub repository."
  type        = string
  default     = ""
  
}

variable "location" {
  description = "Specifies the the location for the Azure resources."
  type        = string
  default     = "eastus2"
}

# AKS Cluster

variable "aks_node_resource_group" {
  description = "Specifies the name of the resource group for the AKS nodes."
  type        = string
  default     = "pe-aks-gitops-rg"
}

# Addons Git
variable "gitops_addons_org" {
  description = "Specifies the Git repository org/user contains for addons."
  type        = string
  default     = "https://github.com/azurenoops"
}
variable "gitops_addons_repo" {
  description = "Specifies the Git repository contains for addons."
  type        = string
  default     = "pe-backstage-azure-workshop"
}
variable "gitops_addons_revision" {
  description = "Specifies the Git repository revision/branch/ref for addons."
  type        = string
  default     = "main"
}
variable "gitops_addons_basepath" {
  description = "Specifies the Git repository base path for addons."
  type        = string
  default     = "terraform/aks/gitops/" # ending slash is important!
}
variable "gitops_addons_path" {
  description = "Specifies the Git repository path for addons."
  type        = string
  default     = "bootstrap/control-plane/addons"
}

variable "postgres_password" {
  description = "Password for the Backstage Postgres database"
  type        = string
  default     = "secretPassword123!"
}
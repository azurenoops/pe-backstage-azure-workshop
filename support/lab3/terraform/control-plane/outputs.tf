output "aks_name" {
  value       = module.aks_cluster.name
  description = "Name of the AKS cluster"
}

output "aks_cluster_fqdn" {
  value       = module.aks_cluster.private_fqdn
  description = "FQDN of the AKS cluster"
}

output "acr_name" {
  value       = module.container_registry.name
  description = "Name of the Azure Container Registry"
}

output "keyvault_name" {
  value       = azurerm_key_vault.key_vault.name
  sensitive   = true
  description = "Name of the Azure Key Vault"
}

output "vnet_name" {
  value       = module.virtual_network.name
  description = "Name of the Virtual Network"
}

output "rg_name" {
  value       = azurerm_resource_group.this.name
  description = "Name of the Resource Group"
}

output "rg_location" {
  value       = azurerm_resource_group.this.location
  description = "Location of the Resource Group"
}
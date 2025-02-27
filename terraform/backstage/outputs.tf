
# Output the necessary variables
output "azure_client_id" {
value = length(azuread_application.backstage-app) > 0 ? azuread_application.backstage-app.application_id : null
}

output "azure_client_secret" {
 
  value = length(azuread_service_principal_password.backstage-sp-password) > 0 ? azuread_service_principal_password.backstage-sp-password.value : null
  sensitive = true
}

output "azure_tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "postgres_host" {
  value = azurerm_postgresql_flexible_server.backstagedbserver.fqdn
}

output "postgres_db_name" {
  value = azurerm_postgresql_flexible_server_database.backstage_plugin_catalog.name
}

output "postgres_username" {
  value = azurerm_postgresql_flexible_server.backstagedbserver.administrator_login
}

output "postgres_password" {
  value = azurerm_postgresql_flexible_server.backstagedbserver.administrator_password
  sensitive = true
}

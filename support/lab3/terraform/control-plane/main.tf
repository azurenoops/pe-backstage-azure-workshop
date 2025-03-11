
################################################################################
# Resource Group: Resource
################################################################################
resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = local.location
  tags     = local.tags
}

################################################################################
# Log Analytics: Module
################################################################################
module "log_analytics_workspace" {
  source              = "./modules/log_analytics"
  name                = local.log_analytics_workspace_name
  location            = local.location
  resource_group_name = azurerm_resource_group.this.name
  solution_plan_map   = var.solution_plan_map
  tags                = local.tags
}


################################################################################
# Virtual Network: Module
################################################################################

module "virtual_network" {
  source                     = "./modules/virtual_network"
  resource_group_name        = azurerm_resource_group.this.name
  location                   = local.location
  vnet_name                  = local.vnet_name
  address_space              = var.vnet_address_space
  log_analytics_workspace_id = module.log_analytics_workspace.id
  tags                       = local.tags

  subnets = [
    {
      name : "SystemSubnet"
      address_prefixes : var.system_node_pool_subnet_address_prefix
      private_endpoint_network_policies_enabled : "Enabled"
      private_link_service_network_policies_enabled : false
      delegation : null
    },
    {
      name : "UserSubnet"
      address_prefixes : var.user_node_pool_subnet_address_prefix
      private_endpoint_network_policies_enabled : "Enabled"
      private_link_service_network_policies_enabled : false
      delegation : null
    },
    {
      name : "PodSubnet"
      address_prefixes : var.pod_subnet_address_prefix
      private_endpoint_network_policies_enabled : "Enabled"
      private_link_service_network_policies_enabled : false
      delegation : "Microsoft.ContainerService/managedClusters"
    },
    {
      name : "ApiServerSubnet"
      address_prefixes : var.api_server_subnet_address_prefix
      private_endpoint_network_policies_enabled : "Enabled"
      private_link_service_network_policies_enabled : false
      delegation : "Microsoft.ContainerService/managedClusters"
    },
    {
      name : "AzureBastionSubnet"
      address_prefixes : var.bastion_subnet_address_prefix
      private_endpoint_network_policies_enabled : "Enabled"
      private_link_service_network_policies_enabled : false
      delegation : null
    },
    {
      name : "VmSubnet"
      address_prefixes : var.vm_subnet_address_prefix
      private_endpoint_network_policies_enabled : "Enabled"
      private_link_service_network_policies_enabled : false
      delegation : null
    }
  ]
}

module "nat_gateway" {
  source                  = "./modules/nat_gateway"
  name                    = local.nat_gateway_name
  resource_group_name     = azurerm_resource_group.this.name
  location                = local.location
  sku_name                = var.nat_gateway_sku_name
  idle_timeout_in_minutes = var.nat_gateway_idle_timeout_in_minutes
  zones                   = var.nat_gateway_zones
  tags                    = local.tags
  subnet_ids              = module.virtual_network.subnet_ids
}

################################################################################
# AKS: Module
################################################################################

module "aks_cluster" {
  source                                  = "./modules/aks"
  name                                    = local.aks_cluster_name
  location                                = local.location
  resource_group_name                     = azurerm_resource_group.this.name
  resource_group_id                       = azurerm_resource_group.this.id
  kubernetes_version                      = var.kubernetes_version
  dns_prefix                              = lower(local.aks_cluster_name)
  private_cluster_enabled                 = var.private_cluster_enabled
  automatic_channel_upgrade               = var.automatic_channel_upgrade
  sku_tier                                = var.sku_tier
  system_node_pool_name                   = var.system_node_pool_name
  system_node_pool_vm_size                = var.system_node_pool_vm_size
  vnet_subnet_id                          = module.virtual_network.subnet_ids["SystemSubnet"]
  pod_subnet_id                           = module.virtual_network.subnet_ids["PodSubnet"]
  api_server_subnet_id                    = module.virtual_network.subnet_ids["ApiServerSubnet"]
  system_node_pool_availability_zones     = var.system_node_pool_availability_zones
  system_node_pool_node_labels            = var.system_node_pool_node_labels
  system_node_pool_node_taints            = var.system_node_pool_node_taints
  system_node_pool_enable_auto_scaling    = var.system_node_pool_enable_auto_scaling
  system_node_pool_enable_host_encryption = var.system_node_pool_enable_host_encryption
  system_node_pool_enable_node_public_ip  = var.system_node_pool_enable_node_public_ip
  system_node_pool_max_pods               = var.system_node_pool_max_pods
  system_node_pool_max_count              = var.system_node_pool_max_count
  system_node_pool_min_count              = var.system_node_pool_min_count
  system_node_pool_node_count             = var.system_node_pool_node_count
  system_node_pool_os_disk_type           = var.system_node_pool_os_disk_type
  tags                                    = local.tags
  network_dns_service_ip                  = var.network_dns_service_ip
  network_plugin                          = var.network_plugin
  outbound_type                           = "userAssignedNATGateway"
  network_service_cidr                    = var.network_service_cidr
  log_analytics_workspace_id              = module.log_analytics_workspace.id
  role_based_access_control_enabled       = var.role_based_access_control_enabled
  tenant_id                               = data.azurerm_client_config.current.tenant_id
  admin_group_object_ids                  = var.admin_group_object_ids
  azure_rbac_enabled                      = var.azure_rbac_enabled
  admin_username                          = var.admin_username
  ssh_public_key                          = var.ssh_public_key
  keda_enabled                            = var.keda_enabled
  vertical_pod_autoscaler_enabled         = var.vertical_pod_autoscaler_enabled
  workload_identity_enabled               = var.workload_identity_enabled
  oidc_issuer_enabled                     = var.oidc_issuer_enabled
  open_service_mesh_enabled               = var.open_service_mesh_enabled
  image_cleaner_enabled                   = var.image_cleaner_enabled
  image_cleaner_interval_hours            = var.image_cleaner_interval_hours
  azure_policy_enabled                    = var.azure_policy_enabled
  http_application_routing_enabled        = var.http_application_routing_enabled
  annotations_allowed                     = var.annotations_allowed
  labels_allowed                          = var.labels_allowed
  authorized_ip_ranges                    = var.authorized_ip_ranges
  vnet_integration_enabled                = var.vnet_integration_enabled

  depends_on = [
    module.nat_gateway,
    module.container_registry
  ]
}

module "node_pool" {
  source                 = "./modules/node_pool"
  resource_group_name    = azurerm_resource_group.this.name
  kubernetes_cluster_id  = module.aks_cluster.id
  name                   = var.user_node_pool_name
  vm_size                = var.user_node_pool_vm_size
  mode                   = var.user_node_pool_mode
  node_labels            = var.user_node_pool_node_labels
  node_taints            = var.user_node_pool_node_taints
  availability_zones     = var.user_node_pool_availability_zones
  vnet_subnet_id         = module.virtual_network.subnet_ids["UserSubnet"]
  pod_subnet_id          = module.virtual_network.subnet_ids["PodSubnet"]
  enable_auto_scaling    = var.user_node_pool_enable_auto_scaling
  enable_host_encryption = var.user_node_pool_enable_host_encryption
  enable_node_public_ip  = var.user_node_pool_enable_node_public_ip
  orchestrator_version   = var.kubernetes_version
  max_pods               = var.user_node_pool_max_pods
  max_count              = var.user_node_pool_max_count
  min_count              = var.user_node_pool_min_count
  node_count             = var.user_node_pool_node_count
  os_type                = var.user_node_pool_os_type
  priority               = var.user_node_pool_priority
  tags                   = local.tags
}

module "helm_charts" {
  source                              = "./modules/helm_charts"
  host                                = module.aks_cluster.host
  username                            = module.aks_cluster.username
  password                            = module.aks_cluster.password
  client_key                          = module.aks_cluster.client_key
  client_certificate                  = module.aks_cluster.client_certificate
  cluster_ca_certificate              = module.aks_cluster.cluster_ca_certificate
  namespace                           = var.namespace
  service_account_name                = var.service_account_name
  email                               = var.email
  subscription_id                     = data.azurerm_client_config.current.subscription_id
  tenant_id                           = data.azurerm_client_config.current.tenant_id
  workload_managed_identity_client_id = azurerm_user_assigned_identity.aks_workload_identity.client_id
  nginx_replica_count                 = 3
  crossplane_provider_packages        = var.crossplane_provider_packages
  kubelet_identity_client_id          = module.aks_cluster.kubelet_identity_client_id
}

################################################################################
# Bastion Host: Module
################################################################################
module "bastion_host" {
  source              = "./modules/bastion_host"
  name                = local.bastion_name
  location            = local.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = module.virtual_network.subnet_ids["AzureBastionSubnet"]
  tags                = local.tags
}

module "virtual_machine" {
  count                               = var.vm_enabled ? 1 : 0
  source                              = "./modules/virtual_machine"
  name                                = var.vm_name
  size                                = var.vm_size
  location                            = local.location
  public_ip                           = var.vm_public_ip
  vm_user                             = var.admin_username
  admin_ssh_public_key                = var.ssh_public_key
  os_disk_image                       = var.vm_os_disk_image
  resource_group_name                 = azurerm_resource_group.this.name
  subnet_id                           = module.virtual_network.subnet_ids["VmSubnet"]
  os_disk_storage_account_type        = var.vm_os_disk_storage_account_type
  boot_diagnostics_storage_account    = module.storage_account.primary_blob_endpoint
  log_analytics_workspace_id          = module.log_analytics_workspace.workspace_id
  log_analytics_workspace_key         = module.log_analytics_workspace.primary_shared_key
  log_analytics_workspace_resource_id = module.log_analytics_workspace.id
  tags                                = local.tags
}

################################################################################
# Container Registry: Module
################################################################################

module "container_registry" {
  source                     = "./modules/container_registry"
  name                       = local.acr_name
  resource_group_name        = azurerm_resource_group.this.name
  location                   = var.location
  sku                        = var.acr_sku
  admin_enabled              = var.acr_admin_enabled
  georeplication_locations   = var.acr_georeplication_locations
  log_analytics_workspace_id = module.log_analytics_workspace.id
  tags                       = local.tags
}

################################################################################
# Storage Account: Module
################################################################################
module "storage_account" {
  source              = "./modules/storage_account"
  name                = local.storage_account_name
  location            = local.location
  resource_group_name = azurerm_resource_group.this.name
  account_kind        = var.storage_account_kind
  account_tier        = var.storage_account_tier
  replication_type    = var.storage_account_replication_type
  tags                = local.tags

}

################################################################################
# Key Vault: Module
################################################################################
# Create the Azure Key Vault
resource "azurerm_key_vault" "key_vault" {
  name                = local.kv_name
  location            = local.location
  resource_group_name = azurerm_resource_group.this.name

  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  enable_rbac_authorization       = true

  tenant_id = data.azurerm_client_config.current.tenant_id
  sku_name  = "standard"

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
}

# Key Vault Secrets - ACR username & password
resource "azurerm_key_vault_secret" "kv_secret_docker_password" {
  name         = "acr-docker-password"
  value        = module.container_registry.admin_password
  key_vault_id = azurerm_key_vault.key_vault.id
  content_type = ""

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }

  depends_on = [azurerm_role_assignment.rbac_key_vault]
}

resource "azurerm_key_vault_secret" "kv_secret_docker_username" {
  name         = "acr-docker-username"
  value        = module.container_registry.admin_username
  key_vault_id = azurerm_key_vault.key_vault.id
  content_type = ""

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }

  depends_on = [azurerm_role_assignment.rbac_key_vault, module.aks_cluster]
}

################################################################################
# Key Vault Identity: Module
################################################################################
resource "azurerm_role_assignment" "rbac_key_vault" {
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

################################################################################
# Workload Identity: Module
################################################################################

resource "azurerm_user_assigned_identity" "aks_workload_identity" {
  name                = "aks_workload_identity"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
}

resource "azurerm_role_assignment" "akspecp_role_assignment" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Owner"
  principal_id         = azurerm_user_assigned_identity.aks_workload_identity.principal_id
}

resource "azurerm_federated_identity_credential" "federated_identity_credential" {
  name                = "${title(var.namespace)}FederatedIdentity"
  resource_group_name = azurerm_resource_group.this.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = module.aks_cluster.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.aks_workload_identity.id
  subject             = "system:serviceaccount:${var.namespace}:${var.service_account_name}"
}

resource "azurerm_role_assignment" "network_contributor_assignment" {
  scope                            = azurerm_resource_group.this.id
  role_definition_name             = "Network Contributor"
  principal_id                     = module.aks_cluster.aks_identity_principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "acr_pull_assignment" {
  role_definition_name             = "AcrPull"
  scope                            = module.container_registry.id
  principal_id                     = module.aks_cluster.kubelet_identity_object_id
  skip_service_principal_aad_check = true
}

module "prometheus" {
  source                        = "./modules/prometheus"
  name                          = var.prometheus_name
  location                      = local.location
  resource_group_name           = azurerm_resource_group.this.name
  public_network_access_enabled = var.prometheus_public_network_access_enabled
  aks_cluster_id                = module.aks_cluster.id
  tags                          = local.tags
}

module "grafana" {
  source                        = "./modules/grafana"
  name                          = var.prometheus_name
  location                      = local.location
  resource_group_name           = azurerm_resource_group.this.name
  public_network_access_enabled = var.grafana_public_network_access_enabled
  azure_monitor_workspace_id    = module.prometheus.id
  sku                           = var.grafana_sku
  zone_redundancy_enabled       = var.grafana_zone_redundancy_enabled
  admin_group_object_id         = var.grafana_admin_user_object_id
  tags                          = local.tags
}

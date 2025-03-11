locals {
  name                         = local.environment
  environment                  = "control-plane"
  location                     = var.location
  resource_group_name          = "${var.resource_group_name}-jrs3"
  aks_cluster_name             = "${var.aks_cluster_name}-jrs3"
  acr_name                     = "${var.acr_name}jrs3"
  kv_name                      = "${var.kv_name}-jrs4"
  storage_account_name         = "${var.storage_account_name}jrs3"
  log_analytics_workspace_name = "${var.log_analytics_workspace_name}-jrs3"
  vnet_name                    = "${var.vnet_name}-jrs3"
  nat_gateway_name             = "${var.nat_gateway_name}-jrs3"
  bastion_name                 = "${var.bastion_name}-jrs3"
  crossplane_provider_packages = ["xpkg.upbound.io/upbound/provider-azure:v0.42.0"]

  tags = {
    Environment = local.name
    Workshop = "Platform Engineering"
  }
}

locals {
  name                = local.environment
  environment         = "backstage"
  location            = var.location
  resource_group_name = "${var.resource_group_name}-<your intitals>"

  kubconfig_path = var.kubconfig_path

  gitops_addons_url      = "${var.gitops_addons_org}/${var.gitops_addons_repo}"
  gitops_addons_basepath = var.gitops_addons_basepath
  gitops_addons_path     = var.gitops_addons_path
  gitops_addons_revision = var.gitops_addons_revision

  github_token = var.github_token

  tags = {
    Blueprint = local.name
  }
}

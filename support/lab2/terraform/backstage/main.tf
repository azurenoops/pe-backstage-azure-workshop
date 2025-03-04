
################################################################################
# Resource Group: Resource
################################################################################
resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = local.location
  tags     = var.tags
}

################################################################################
# Postgres: Module
################################################################################
resource "azurerm_postgresql_flexible_server" "backstagedbserver" {
  name                          = "backstage-postgresql-server"
  location                      = local.location
  public_network_access_enabled = true
  administrator_password        = var.postgres_password
  resource_group_name           = azurerm_resource_group.this.name
  administrator_login           = "psqladminun"
  sku_name                      = "GP_Standard_D4s_v3"
  version                       = "12"
  zone                          = 1
}

# Define the PostgreSQL database
resource "azurerm_postgresql_flexible_server_database" "backstage_plugin_catalog" {
  name      = "backstage_plugin_catalog"
  server_id = azurerm_postgresql_flexible_server.backstagedbserver.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_all" {
  name             = "AllowAll"
  server_id        = azurerm_postgresql_flexible_server.backstagedbserver.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}

################################################################################
# AKS: Public IP for predictable backstage service & redirect URI
################################################################################

resource "azurerm_public_ip" "backstage_public_ip" {
  name                = "backstage-public-ip"
  location            = azurerm_resource_group.this.location
  resource_group_name = var.aks_node_resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
}

################################################################################
# Backstage: Service Account & Secret
################################################################################
resource "kubernetes_namespace" "backstage_nammespace" {
  count = local.helm_release ? 1 : 0
  metadata {
    name = "backstage"
  }
}
resource "kubernetes_service_account" "backstage_service_account" {
  count      = local.helm_release ? 1 : 0
  depends_on = [kubernetes_namespace.backstage_nammespace]
  metadata {
    name      = "backstage-service-account"
    namespace = "backstage"
  }

}

resource "kubernetes_role" "backstage_pod_reader" {
  count      = local.helm_release ? 1 : 0
  depends_on = [kubernetes_service_account.backstage_service_account]
  metadata {
    name      = "backstage-pod-reader"
    namespace = "backstage"
  }

  rule {
    api_groups = [""]
    resources = [
      "pods",
      "services",
      "replicationcontrollers",
      "persistentvolumeclaims",
      "configmaps",
      "secrets",
      "events",
      "pods/log",
      "pods/status",
    ]
    verbs = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding" "backstage_role_binding" {
  count      = local.helm_release ? 1 : 0
  depends_on = [kubernetes_role.backstage_pod_reader]
  metadata {
    name      = "backstage-role-binding"
    namespace = "backstage"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.backstage_pod_reader[0].metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.backstage_service_account[0].metadata[0].name
    namespace = kubernetes_service_account.backstage_service_account[0].metadata[0].namespace
  }
}

resource "kubernetes_secret" "backstage_service_account_secret" {
  count      = local.helm_release ? 1 : 0
  depends_on = [kubernetes_service_account.backstage_service_account]
  metadata {
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.backstage_service_account[0].metadata[0].name
    }
    name      = "backstage-service-account-secret"
    namespace = kubernetes_service_account.backstage_service_account[0].metadata[0].namespace
  }

  type                           = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true
}

################################################################################
# Backstage: Helm Release
################################################################################

resource "kubernetes_secret" "tls_secret" {
  count      = var.helm_release ? 1 : 0
  depends_on = [kubernetes_namespace.backstage_nammespace]

  metadata {
    name      = "my-tls-secret"
    namespace = kubernetes_namespace.backstage_nammespace[0].metadata[0].name
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = file("tls.crt") # Adjust the path accordingly
    "tls.key" = file("tls.key") # Adjust the path accordingly
  }
}

resource "helm_release" "backstage" {
  count      = var.helm_release ? 1 : 0
  depends_on = [kubernetes_secret.tls_secret]
  name       = "backstage"
  repository = "oci://backstageacr<your intitals>.azurecr.us"
  chart      = "backstagechart"
  version    = "1.0.0"

  set {
    name  = "image.repository"
    value = "backstageacr<your intitals>.azurecr.us/backstage"
  }
  set {
    name  = "image.tag"
    value = "v1"
  }
  set {
    name  = "env.K8S_CLUSTER_NAME"
    value = var.aks_name
  }

  set {
    name  = "env.K8S_CLUSTER_URL"
    value = "https://${var.aks_name}"
  }

  set {
    name  = "env.K8S_SERVICE_ACCOUNT_TOKEN"
    value = kubernetes_secret.backstage_service_account_secret[0].data.token
  }

  set {
    name  = "env.GITHUB_TOKEN"
    value = local.github_token
  }

  set {
    name  = "env.GITOPS_REPO"
    value = local.gitops_addons_url
  }

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
  set {
    name  = "service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-resource-group"
    value = var.aks_node_resource_group
  }

  set {
    name  = "service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-ipv4"
    value = azurerm_public_ip.backstage_public_ip.ip_address
  }
  set {
    name  = "image.tag"
    value = "v1"
  }

  set {
    name  = "env.BASE_URL"
    value = "https://${azurerm_public_ip.backstage_public_ip.ip_address}"
  }

  set {
    name  = "env.POSTGRES_HOST"
    value = azurerm_postgresql_flexible_server.backstagedbserver.fqdn
  }

  set {
    name  = "env.POSTGRES_PORT"
    value = "5432"
  }

  set {
    name  = "env.POSTGRES_USER"
    value = azurerm_postgresql_flexible_server.backstagedbserver.administrator_login
  }

  set {
    name  = "env.POSTGRES_PASSWORD"
    value = azurerm_postgresql_flexible_server.backstagedbserver.administrator_password
  }

  set {
    name  = "env.POSTGRES_DB"
    value = azurerm_postgresql_flexible_server_database.backstage_plugin_catalog.name
  }

  set {
    name  = "env.AZURE_CLIENT_ID"
    value = azuread_application.backstage-app.client_id
  }

  set {
    name  = "env.AZURE_CLIENT_SECRET"
    value = azuread_service_principal_password.backstage-sp-password.value
  }

  set {
    name  = "env.AZURE_TENANT_ID"
    value = data.azurerm_client_config.current.tenant_id
  }
  set {
    name  = "podAnnotations.backstage\\.io/kubernetes-id"
    value = "${var.aks_name}-component"
  }

  set {
    name  = "labels.kubernetesId"
    value = "${var.aks_name}-component"
  }
}

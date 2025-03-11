variable "resource_group_name" {
  description = "Specifies the name of the resource group."
  default     = "rg-pe-aks-gitops"
  type        = string
}

variable "location" {
  description = "Specifies the the location for the Azure resources."
  type        = string
  default     = "usgovvirginia"
}

variable "subscription_id" {
  description = "Specifies the subscription id for the Azure resources."
  type        = string
  default     = null
  
}

# Log Analytics variables
variable "log_analytics_workspace_name" {
  description = "Specifies the name of the log analytics workspace"
  default     = "Workspace"
  type        = string
}

variable "solution_plan_map" {
  description = "Specifies solutions to deploy to log analytics workspace"
  default     = {
    ContainerInsights= {
      product   = "OMSGallery/ContainerInsights"
      publisher = "Microsoft"
    }
  }
  type = map(any)
}

# AKS  variables
variable "aks_cluster_name" {
  description = "Specifies the name of the Azure Kubernetes Service."
  type        = string
  default     = "aks-pe-gitops"
}

variable "private_cluster_enabled" {
  description = "(Optional) Specifies wether the AKS cluster be private or not."
  default     = false
  type        = bool
}

variable "log_analytics_workspace_enabled" {
  description = "(Optional) Specifies whether to enable the log analytics workspace."
  default     = true
  type        = bool  
}
  
variable "role_based_access_control_enabled" {
  description = "(Required) Is Role Based Access Control Enabled? Changing this forces a new resource to be created."
  default     = true
  type        = bool
}

variable "admin_group_object_ids" {
  description = "(Optional) A list of Object IDs of Azure Active Directory Groups which should have Admin Role on the Cluster."
  default     = []
  type        = list(string)
}

variable "azure_rbac_enabled" {
  description = "(Optional) Is Role Based Access Control based on Azure AD enabled?"
  default     = true
  type        = bool
}

variable "sku_tier" {
  description = "(Optional) The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free and Paid (which includes the Uptime SLA). Defaults to Free."
  default     = "Free"
  type        = string

  validation {
    condition = contains( ["Free", "Paid"], var.sku_tier)
    error_message = "The sku tier is invalid."
  }
}

variable "kubernetes_version" {
  description = "Specifies the AKS Kubernetes version"
  type        = string
}

variable "system_node_pool_vm_size" {
  description = "Specifies the vm size of the system node pool"
  default     = "Standard_F8s_v2"
  type        = string
}

variable "system_node_pool_availability_zones" {
  description = "Specifies the availability zones of the system node pool"
  default     = ["1", "2", "3"]
  type        = list(string)
}

variable "network_dns_service_ip" {
  description = "Specifies the DNS service IP"
  default     = "172.16.0.10"
  type        = string
}

variable "network_service_cidr" {
  description = "Specifies the service CIDR"
  default     = "172.16.0.0/16"
  type        = string
}

variable "network_plugin" {
  description = "Specifies the network plugin of the AKS cluster"
  default     = "azure"
  type        = string
}

variable "annotations_allowed" {
  description = "(Optional) Specifies a comma-separated list of Kubernetes annotation keys that will be used in the resource's labels metric."
  type        = string
  default     = null
}

variable "labels_allowed" {
  description = "(Optional) Specifies a Comma-separated list of additional Kubernetes label keys that will be used in the resource's labels metric."
  type        = string
  default     = null
}

variable "authorized_ip_ranges" {
  description = "(Optional) Set of authorized IP ranges to allow access to API server."
  type        = list(string)
  default     = []
}

variable "vnet_integration_enabled" {
  description = "(Optional) Should API Server VNet Integration be enabled? For more details please visit Use API Server VNet Integration."
  type        = bool
  default     = false
}

variable "system_node_pool_name" {
  description = "Specifies the name of the system node pool"
  default     =  "system"
  type        = string
}

variable "system_node_pool_enable_auto_scaling" {
  description = "(Optional) Whether to enable auto-scaler. Defaults to false."
  type          = bool
  default       = true
}

variable "system_node_pool_enable_host_encryption" {
  description = "(Optional) Should the nodes in this Node Pool have host encryption enabled? Defaults to false."
  type          = bool
  default       = false
} 

variable "system_node_pool_enable_node_public_ip" {
  description = "(Optional) Should each node have a Public IP Address? Defaults to false. Changing this forces a new resource to be created."
  type          = bool
  default       = false
} 

variable "system_node_pool_max_pods" {
  description = "(Optional) The maximum number of pods that can run on each agent. Changing this forces a new resource to be created."
  type          = number
  default       = 50
}

variable "system_node_pool_node_labels" {
  description = "(Optional) A map of Kubernetes labels which should be applied to nodes in this Node Pool. Changing this forces a new resource to be created."
  type          = map(any)
  default       = {}
} 

variable "system_node_pool_node_taints" {
  description = "(Optional) A list of Kubernetes taints which should be applied to nodes in the agent pool (e.g key=value:NoSchedule). Changing this forces a new resource to be created."
  type          = list(string)
  default       = ["CriticalAddonsOnly=true:NoSchedule"]
}  

variable "system_node_pool_os_disk_type" {
  description = "(Optional) The type of disk which should be used for the Operating System. Possible values are Ephemeral and Managed. Defaults to Managed. Changing this forces a new resource to be created."
  type          = string
  default       = "Ephemeral"
} 

variable "system_node_pool_max_count" {
  description = "(Required) The maximum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be greater than or equal to min_count."
  type          = number
  default       = 10
}

variable "system_node_pool_min_count" {
  description = "(Required) The minimum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be less than or equal to max_count."
  type          = number
  default       = 3
}

variable "system_node_pool_node_count" {
  description = "(Optional) The initial number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be a value in the range min_count - max_count."
  type          = number
  default       = 3
}

variable "user_node_pool_name" {
  description = "(Required) Specifies the name of the node pool."
  type        = string
  default     = "user"
}

variable "user_node_pool_vm_size" {
  description = "(Required) The SKU which should be used for the Virtual Machines used in this Node Pool. Changing this forces a new resource to be created."
  type        = string
  default     = "Standard_F8s_v2"
}

variable "user_node_pool_availability_zones" {
  description = "(Optional) A list of Availability Zones where the Nodes in this Node Pool should be created in. Changing this forces a new resource to be created."
  type        = list(string)
  default = ["1", "2", "3"]
}

variable "user_node_pool_enable_auto_scaling" {
  description = "(Optional) Whether to enable auto-scaler. Defaults to false."
  type          = bool
  default       = true
}

variable "user_node_pool_enable_host_encryption" {
  description = "(Optional) Should the nodes in this Node Pool have host encryption enabled? Defaults to false."
  type          = bool
  default       = false
} 

variable "user_node_pool_enable_node_public_ip" {
  description = "(Optional) Should each node have a Public IP Address? Defaults to false. Changing this forces a new resource to be created."
  type          = bool
  default       = false
} 

variable "user_node_pool_max_pods" {
  description = "(Optional) The maximum number of pods that can run on each agent. Changing this forces a new resource to be created."
  type          = number
  default       = 50
}

variable "user_node_pool_mode" {
  description = "(Optional) Should this Node Pool be used for System or User resources? Possible values are System and User. Defaults to User."
  type          = string
  default       = "User"
} 

variable "user_node_pool_node_labels" {
  description = "(Optional) A map of Kubernetes labels which should be applied to nodes in this Node Pool. Changing this forces a new resource to be created."
  type          = map(any)
  default       = {}
} 

variable "user_node_pool_node_taints" {
  description = "(Optional) A list of Kubernetes taints which should be applied to nodes in the agent pool (e.g key=value:NoSchedule). Changing this forces a new resource to be created."
  type          = list(string)
  default       = []
} 

variable "user_node_pool_os_disk_type" {
  description = "(Optional) The type of disk which should be used for the Operating System. Possible values are Ephemeral and Managed. Defaults to Managed. Changing this forces a new resource to be created."
  type          = string
  default       = "Ephemeral"
} 

variable "user_node_pool_os_type" {
  description = "(Optional) The Operating System which should be used for this Node Pool. Changing this forces a new resource to be created. Possible values are Linux and Windows. Defaults to Linux."
  type          = string
  default       = "Linux"
} 

variable "user_node_pool_priority" {
  description = "(Optional) The Priority for Virtual Machines within the Virtual Machine Scale Set that powers this Node Pool. Possible values are Regular and Spot. Defaults to Regular. Changing this forces a new resource to be created."
  type          = string
  default       = "Regular"
} 

variable "user_node_pool_max_count" {
  description = "(Required) The maximum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be greater than or equal to min_count."
  type          = number
  default       = 10
}

variable "user_node_pool_min_count" {
  description = "(Required) The minimum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be less than or equal to max_count."
  type          = number
  default       = 3
}

variable "user_node_pool_node_count" {
  description = "(Optional) The initial number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be a value in the range min_count - max_count."
  type          = number
  default       = 3
}

variable "azure_policy_enabled" {
  description = "(Optional) Should the Azure Policy Add-On be enabled? For more details please visit Understand Azure Policy for Azure Kubernetes Service"
  type        = bool
  default     = true
}

variable "microsoft_defender_enabled" {
  description = "(Optional) Should the Microsoft Defender for Cloud Add-On be enabled? For more details please visit Understand Microsoft Defender for Cloud for Azure Kubernetes Service"
  type        = bool
  default     = true  
}

variable "automatic_channel_upgrade" {
  description = "(Optional) Should the AKS cluster be automatically upgraded to the latest version? For more details please visit Understand automatic upgrades for Azure Kubernetes Service"
  type        = string
  default     = "stable"  
}

variable "admin_username" {
  description = "(Required) Specifies the admin username of the jumpbox virtual machine and AKS worker nodes."
  type        = string
  default     = "azadmin"
}

variable "ssh_public_key" {
  description = "(Required) Specifies the SSH public key for the jumpbox virtual machine and AKS worker nodes."
  type        = string
}

variable "keda_enabled" {
  description = "(Optional) Specifies whether KEDA Autoscaler can be used for workloads."
  type        = bool
  default     = true
}

variable "vertical_pod_autoscaler_enabled" {
  description = "(Optional) Specifies whether Vertical Pod Autoscaler should be enabled."
  type        = bool
  default     = true
}

variable "workload_identity_enabled" {
  description = "(Optional) Specifies whether Azure AD Workload Identity should be enabled for the Cluster. Defaults to false."
  type        = bool
  default     = true
}

variable "oidc_issuer_enabled" {
  description = "(Optional) Enable or Disable the OIDC issuer URL."
  type        = bool
  default     = true
}

variable "open_service_mesh_enabled" {
  description = "(Optional) Is Open Service Mesh enabled? For more details, please visit Open Service Mesh for AKS."
  type        = bool
  default     = true
}

variable "image_cleaner_enabled" {
  description = "(Optional) Specifies whether Image Cleaner is enabled."
  type        = bool
  default     = true
}

variable "image_cleaner_interval_hours" {
  type        = number
  default     = 48
  description = "(Optional) Specifies the interval in hours when images should be cleaned up. Defaults to `48`."
}

variable "http_application_routing_enabled" {
  description = "(Optional) Should HTTP Application Routing be enabled?"
  type        = bool
  default     = false
}

variable "vm_enabled" {
  description = "(Optional) Specifies whether create a virtual machine"
  type = bool
  default = false
}

variable "vm_name" {
  description = "Specifies the name of the jumpbox virtual machine"
  default     = "Vm"
  type        = string
}

variable "vm_public_ip" {
  description = "(Optional) Specifies whether create a public IP for the virtual machine"
  type = bool
  default = false
}

variable "vm_size" {
  description = "Specifies the size of the jumpbox virtual machine"
  default     = "Standard_DS1_v2"
  type        = string
}

variable "vm_os_disk_storage_account_type" {
  description = "Specifies the storage account type of the os disk of the jumpbox virtual machine"
  default     = "Premium_LRS"
  type        = string

  validation {
    condition = contains(["Premium_LRS", "Premium_ZRS", "StandardSSD_LRS", "StandardSSD_ZRS",  "Standard_LRS"], var.vm_os_disk_storage_account_type)
    error_message = "The storage account type of the OS disk is invalid."
  }
}

variable "vm_os_disk_image" {
  type        = map(string)
  description = "Specifies the os disk image of the virtual machine"
  default     = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2" 
    version   = "latest"
  }
}

variable "web_app_routing_enabled" {
  description = "(Optional) Should Web App Routing be enabled?"
  type        = bool
  default     = false
}

# ACR variables
variable "acr_name" {
  description = "Specifies the name of the Azure Container Registry."
  type        = string
  default     = "controlplaneacr"  
}

variable "acr_sku" {
  description = "Specifies the name of the container registry"
  type        = string
  default     = "Premium"

  validation {
    condition = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "The container registry sku is invalid."
  }
}

variable "acr_admin_enabled" {
  description = "Specifies whether admin is enabled for the container registry"
  type        = bool
  default     = true
}

variable "acr_georeplication_locations" {
  description = "(Optional) A list of Azure locations where the container registry should be geo-replicated."
  type        = list(string)
  default     = []
}

# Key Vault variables
variable "kv_name" {
  description = "Specifies the name of the Azure Key Vault."
  type        = string
  default     = "kv-pe-aks-gitops"  
}

# VNET variables
variable "vnet_name" {
  description = "Specifies the name of the AKS subnet"
  default     = "VNet"
  type        = string
}

variable "vnet_address_space" {
  description = "Specifies the address prefix of the AKS subnet"
  default     =  ["10.0.0.0/8"]
  type        = list(string)
}

variable "system_node_pool_subnet_address_prefix" {
  description = "Specifies the address prefix of the subnet that hosts the system node pool"
  default     =  ["10.240.0.0/16"]
  type        = list(string)
}

variable "user_node_pool_subnet_address_prefix" {
  description = "Specifies the address prefix of the subnet that hosts the user node pool"
  type        = list(string)
  default     = ["10.241.0.0/16"]
}

variable "pod_subnet_address_prefix" {
  description = "Specifies the address prefix of the jumbox subnet"
  default     = ["10.242.0.0/16"]
  type        = list(string)
}

variable "api_server_subnet_name" {
  description = "Specifies the address prefix of the API Server subnet, when API Server VNET Integration is enabled."
  default     = "ApiServerSubnet"
  type        = string
}

variable "api_server_subnet_address_prefix" {
  description = "Specifies the address prefix of the API Server subnet, when API Server VNET Integration is enabled."
  default     = ["10.243.0.0/27"]
  type        = list(string)
}


variable "vm_subnet_address_prefix" {
  description = "Specifies the address prefix of the subnet that contains the jumpbox virtual machine and private endpoints."
  default     = ["10.243.1.0/24"]
  type        = list(string)
}

# Basion variables
variable "bastion_name" {
  description = "Specifies the name of the Azure Bastion."
  default     = "bas-pe-aks-gitops"
  type        = string
}

variable "bastion_subnet_address_prefix" {
  description = "Specifies the address prefix of the firewall subnet"
  default     = ["10.243.2.0/24"]
  type        = list(string)
}

# NAT Gateway variables
variable "nat_gateway_name" {
  description = "(Required) Specifies the name of the Azure OpenAI Service"
  type = string
  default = "NatGateway"
}

variable "nat_gateway_sku_name" {
  description = "(Optional) The SKU which should be used. At this time the only supported value is Standard. Defaults to Standard"
  type = string
  default = "Standard"
}

variable "nat_gateway_idle_timeout_in_minutes" {
  description = "(Optional) The idle timeout which should be used in minutes. Defaults to 4."
  type = number
  default = 4
}

variable "nat_gateway_zones" {
  description = " (Optional) A list of Availability Zones in which this NAT Gateway should be located. Changing this forces a new NAT Gateway to be created."
  type = list(string)
  default = ["1"]
}

# Helm Chart variables
variable "namespace" {
  description = "Specifies the namespace of the workload application that accesses the Azure OpenAI Service."
  type = string
  default = "pe-workshop"
}

variable "service_account_name" {
  description = "Specifies the name of the service account of the workload application that accesses the Azure OpenAI Service."
  type = string
  default = "pe-workshop-sa"
}

variable "email" {
  description = "Specifies the email address for the cert-manager cluster issuer."
  type = string
  default = "pe-workshop@contoso.com"
}

variable "crossplane_provider_packages" {
  description = "(Required) Contains the crossplane provider packages to install."
  type        = list
  default     = []
}

# Storage Account variables
variable "storage_account_name" {
  description = "(Required) Specifies the name of the storage account"
  type        = string  
  default     = "sapegitops"  
}
variable "storage_account_kind" {
  description = "(Optional) Specifies the account kind of the storage account"
  default     = "StorageV2"
  type        = string

   validation {
    condition = contains(["Storage", "StorageV2"], var.storage_account_kind)
    error_message = "The account kind of the storage account is invalid."
  }
}

variable "storage_account_tier" {
  description = "(Optional) Specifies the account tier of the storage account"
  default     = "Standard"
  type        = string

   validation {
    condition = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "The account tier of the storage account is invalid."
  }
}

variable "storage_account_replication_type" {
  description = "(Optional) Specifies the replication type of the storage account"
  default     = "LRS"
  type        = string

  validation {
    condition = contains(["LRS", "ZRS", "GRS", "GZRS", "RA-GRS", "RA-GZRS"], var.storage_account_replication_type)
    error_message = "The replication type of the storage account is invalid."
  }
}

# Prometheus variables
variable "prometheus_name" {
  description = "Specifies the name of the Azure Managed Prometheus workspace."
  type = string
  default = "Prometheus"
}

variable "prometheus_public_network_access_enabled" {
  description = "(Optional) Specifies whether to enable traffic over the public interface for the Azure Managed Prometheus workspace. Defaults to true."
  type        = bool
  default     = true
}

variable "grafana_name" {
  description = "Specifies the name of the Azure Managed Grafana instance."
  type = string
  default = "Prometheus"
}

variable "grafana_public_network_access_enabled" {
  description = "(Optional) Specifies whether to enable traffic over the public interface for the Azure Managed Grafana instance. Defaults to true."
  type        = bool
  default     = true
}

variable "grafana_sku" {
  description = "(Optional) Specifies the name of the SKU used for the Azure Managed Grafana resource. Possible values are Standard and Essential. Defaults to Standard. Changing this forces a new Dashboard Grafana to be created."
  type        = string
  default     = "Standard"
}

variable "grafana_zone_redundancy_enabled" {
  description = "(Optional) Specifies whether to enable zone redundancy for the Azure Managed Grafana resource. Defaults to false. Changing this forces a new Dashboard Grafana to be created."
  type        = bool
  default     = false
}

variable "grafana_admin_user_object_id" {
  description = "(Required) The object id of a Microsoft Entra ID user who should be assigned the Grafana Admin role over the Azure Managed Grafana resource."
  type        = string
  default     = null
}

## Azure config variables ##
variable "client_id" {}

variable "client_secret" {}

## Resource group variables ##
variable "resource_group_name" {
  type = string
}

variable location {
  type = string
}

## Key pub 
variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

## AKS kubernetes cluster variables ##
variable "cluster_name" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "vnet_subnet_id" {
  description = "Resource id of the Virtual Network subnet"
  type        = string
}

variable "subnet_name" {
  type = string
}

variable "address_space" {
  description = "The address space (CIDR notation) of the Virtual Network"
  type        = list(string)
}

variable "subnet_address_space" {
  description = "The address space (CIDR notation) of the Virtual Network subnet"
  type        = string
}

variable "agent_count" {
  type = string
}

variable "dns_prefix" {
  type = string
}

variable "admin_username" {
  default = "azureuser"
}

variable log_analytics_workspace_name {
  default = "testLogAnalyticsWorkspaceName"
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable log_analytics_workspace_location {
  default = "eastus"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable log_analytics_workspace_sku {
  default = "PerGB2018"
}
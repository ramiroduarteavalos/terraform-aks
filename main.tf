## Azure resource provider ##
provider "azurerm" {
  version = ">= 0.12"
  features {}
}

resource "random_id" "log_analytics_workspace_name_suffix" {
    byte_length = 8
}

resource "azurerm_log_analytics_workspace" "k8s" {
    # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
    name                = "${var.log_analytics_workspace_name}-${random_id.log_analytics_workspace_name_suffix.dec}"
    location            = var.log_analytics_workspace_location
    resource_group_name = var.resource_group_name
    sku                 = var.log_analytics_workspace_sku
}

resource "azurerm_log_analytics_solution" "k8s" {
    solution_name         = "ContainerInsights"
    location              = azurerm_log_analytics_workspace.k8s.location
    resource_group_name   = var.resource_group_name
    workspace_resource_id = azurerm_log_analytics_workspace.k8s.id
    workspace_name        = azurerm_log_analytics_workspace.k8s.name

    plan {
        publisher = "Microsoft"
        product   = "OMSGallery/ContainerInsights"
    }
}

resource "azurerm_kubernetes_cluster" "k8s" { 

  name                        = var.cluster_name
  location                    = var.location
  resource_group_name         = var.resource_group_name  
  dns_prefix                  = var.dns_prefix
  private_cluster_enabled   = true 

  default_node_pool {
    name                      = "app"
    node_count                = var.agent_count
    vm_size                   = "Standard_B12ms"
    os_disk_size_gb           = 30
    vnet_subnet_id            = var.vnet_subnet_id
    max_pods                  = 70
    min_count                 = "2"
    max_count                 = "5"
    enable_auto_scaling       = "true"
    #orchestrator_version     = "1.16.10"
    enable_node_public_ip     = "false"
    type                      = "VirtualMachineScaleSets"
  }

  network_profile {
    network_plugin                      = "azure"
    load_balancer_sku                   = "standard"
    load_balancer_profile {
      managed_outbound_ip_count         = "1"
    } 
    service_cidr                        = "10.0.0.0/16"
    dns_service_ip                      = "10.0.0.10"
    docker_bridge_cidr                  = "172.17.0.1/16"
    #outbound_type                       = "loadBalancer"
  }

  linux_profile {
    admin_username = var.admin_username
    ## SSH key is generated using "tls_private_key" resource
    ssh_key {
      key_data = file(var.ssh_public_key)
    }    
  } 

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.k8s.id
    }
  }

  tags = {
    Environment = "Development"
  }

}

## Private key for the kubernetes cluster ##
resource "tls_private_key" "key" {
  algorithm   = "RSA"
}

## Save the private key in the local workspace ##
resource "null_resource" "save-key" {
  triggers = {
    key = tls_private_key.key.private_key_pem
  }

  provisioner "local-exec" {
    command = <<EOF
      mkdir -p ${path.module}/.ssh
      echo "${tls_private_key.key.private_key_pem}" > ${path.module}/.ssh/id_rsa
      chmod 0600 ${path.module}/.ssh/id_rsa
EOF
  }
}
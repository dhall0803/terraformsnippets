terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "=3.34.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  location = "UK South"
  location_short = "uks"
  environment = "dev"
  resource_suffix = "${random_id.random_id.hex}-${local.environment}-${local.location_short}"
  delete_tag_value = "yes"
}

// Random id for resources 

resource "random_id" "random_id" {
  byte_length = 4
}

resource "azurerm_resource_group" "example" {
  name     = "rg-akslearning-${local.resource_suffix}"
  location = local.location
}

resource "azurerm_kubernetes_cluster" "example" {
  name                = "aks-akslearning-${local.resource_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  dns_prefix          = "akslearning-${local.resource_suffix}"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }


  tags = {
    Environment = local.environment
    Delete = local.delete_tag_value
  }
}

output "name" {
  value = azurerm_kubernetes_cluster.example.name
}
  
output "fqdn" {
  value = azurerm_kubernetes_cluster.example.fqdn
}

output "resource_group_name" {
  value = azurerm_kubernetes_cluster.example.resource_group_name
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.example.kube_config_raw
  sensitive = true
}
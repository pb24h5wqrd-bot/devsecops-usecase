terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
  }
}

provider "azurerm" {
  features {}
}

# 1️⃣ Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "devsecops-rg"
  location = "East US"
}

# 2️⃣ Create an AKS cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "devsecops-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "devsecops"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }

  # Optional: enable RBAC and OIDC for workloads
  role_based_access_control_enabled = true
  oidc_issuer_enabled               = true
}

# 3️⃣ Connect the Kubernetes provider dynamically using the AKS cluster’s kubeconfig
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
}

# 4️⃣ Create a namespace
resource "kubernetes_namespace" "demo" {
  metadata {
    name = "demo"
  }
}

# 5️⃣ Create a ConfigMap in that namespace
resource "kubernetes_config_map" "app_config" {
  metadata {
    name      = "app-config"
    namespace = kubernetes_namespace.demo.metadata[0].name
  }

  data = {
    APP_MODE = "secure"
  }
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "lokka_mcp" {
  name     = var.resource_group_name
  location = var.location
}

# Container Registry
resource "azurerm_container_registry" "lokka_mcp" {
  name                = var.registry_name
  resource_group_name = azurerm_resource_group.lokka_mcp.name
  location            = azurerm_resource_group.lokka_mcp.location
  sku                 = "Basic"
  admin_enabled       = true
}

# Log Analytics Workspace for Container Apps
resource "azurerm_log_analytics_workspace" "lokka_mcp" {
  name                = "${var.prefix}-logs"
  location            = azurerm_resource_group.lokka_mcp.location
  resource_group_name = azurerm_resource_group.lokka_mcp.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Container Apps Environment
resource "azurerm_container_app_environment" "lokka_mcp" {
  name                       = "${var.prefix}-env"
  location                   = azurerm_resource_group.lokka_mcp.location
  resource_group_name        = azurerm_resource_group.lokka_mcp.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.lokka_mcp.id
}

# Container App
resource "azurerm_container_app" "lokka_mcp" {
  name                         = "${var.prefix}-server"
  container_app_environment_id = azurerm_container_app_environment.lokka_mcp.id
  resource_group_name          = azurerm_resource_group.lokka_mcp.name
  revision_mode                = "Single"

  registry {
    server               = azurerm_container_registry.lokka_mcp.login_server
    username             = azurerm_container_registry.lokka_mcp.admin_username
    password_secret_name = "registry-password"
  }

  secret {
    name  = "registry-password"
    value = azurerm_container_registry.lokka_mcp.admin_password
  }

  secret {
    name  = "tenant-id"
    value = var.tenant_id
  }

  secret {
    name  = "client-id"
    value = var.client_id
  }

  secret {
    name  = "client-secret"
    value = var.client_secret
  }

  template {
    container {
      name   = "${var.prefix}-server"
      image  = "${azurerm_container_registry.lokka_mcp.login_server}/${var.image_name}:${var.image_tag}"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name        = "TENANT_ID"
        secret_name = "tenant-id"
      }

      env {
        name        = "CLIENT_ID"
        secret_name = "client-id"
      }

      env {
        name        = "CLIENT_SECRET"
        secret_name = "client-secret"
      }

      env {
        name  = "USE_GRAPH_BETA"
        value = "true"
      }

      env {
        name  = "HOME"
        value = "/root"
      }

      env {
        name  = "TMPDIR"
        value = "/tmp"
      }

      env {
        name  = "PORT"
        value = "3000"
      }
    }

    min_replicas = 0
    max_replicas = 3
  }

  ingress {
    allow_insecure_connections = false
    external_enabled          = true
    target_port               = 3000

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  lifecycle {
    ignore_changes = [
      template[0].container[0].image
    ]
  }
}

# Data source to get the current Azure client configuration
data "azurerm_client_config" "current" {}

# Azure AD Application Registration (if needed)
resource "azuread_application" "lokka_mcp" {
  count        = var.create_app_registration ? 1 : 0
  display_name = "${var.prefix}-mcp-app"

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read
      type = "Scope"
    }

    resource_access {
      id   = "19dbc75e-c2e2-444c-a770-ec69d8559fc7" # Directory.ReadWrite.All
      type = "Role"
    }

    resource_access {
      id   = "62a82d76-70ea-41e2-9197-370581804d09" # Group.ReadWrite.All
      type = "Role"
    }
  }

  web {
    redirect_uris = ["http://localhost:3000/auth/callback"]
  }
}

resource "azuread_application_password" "lokka_mcp" {
  count             = var.create_app_registration ? 1 : 0
  application_id    = azuread_application.lokka_mcp[0].id
  display_name      = "${var.prefix}-mcp-secret"
  end_date_relative = "8760h" # 1 year
}

resource "azuread_service_principal" "lokka_mcp" {
  count     = var.create_app_registration ? 1 : 0
  client_id = azuread_application.lokka_mcp[0].client_id
}
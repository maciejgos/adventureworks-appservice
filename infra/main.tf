terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.1.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {

  }
}

resource "random_password" "pwd" {
  length = 12
}

locals {
  dbadmin    = "sqldbadmin"
  dbpassword = random_password.pwd.result
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-adv-samples"
  location = "westeurope"
}

resource "azurerm_mssql_server" "db" {
  #checkov:skip=CKV_AZURE_113: This is only development environment
  #checkov:skip=CKV_AZURE_23: Auditing is not required for this env
  #checkov:skip=CKV_AZURE_24: Auditing is not required for this env
  lifecycle {
    ignore_changes = [
      azuread_administrator
    ]
  }
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  name                          = "adv001server"
  administrator_login           = local.dbadmin
  administrator_login_password  = local.dbpassword
  public_network_access_enabled = true
  version                       = "12.0"
  minimum_tls_version           = "1.2"

}

resource "azurerm_mssql_database" "db" {
  server_id   = azurerm_mssql_server.db.id
  name        = "advdb"
  sample_name = "AdventureWorksLT"
  sku_name    = "Basic"
}

resource "azurerm_mssql_firewall_rule" "db" {
  name             = "AllowAllAzureServicesRule"
  server_id        = azurerm_mssql_server.db.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_service_plan" "app" {
  name                = "adv001plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "app" {
  name                = "adv001service"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.app.id

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Server=tcp:adv001server.database.windows.net,1433;Initial Catalog=advdb;User ID=${local.dbadmin}; Password=${local.dbpassword}; Persist Security Info=False;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  }
}

resource "azurerm_cdn_profile" "cdn" {
  name                = "adv001cdnprofile"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard_Microsoft"
}

resource "azurerm_cdn_endpoint" "cdn" {
  name                = "adv-portal"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  profile_name        = azurerm_cdn_profile.cdn.name
  origin {
    name      = "adv-portal"
    host_name = azurerm_linux_web_app.app.default_hostname
  }

}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.99.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {

  }
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-adv-samples"
  location = "westeurope"
}

resource "azurerm_mssql_server" "db" {
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  name                          = "adv001server"
  administrator_login           = "sqldbadmin"
  administrator_login_password  = "P@ssw0rd!@#"
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

resource "azurerm_app_service_plan" "app" {
  name                = "adv001plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    tier = "Free"
    size = "F1"
  }
}

resource "azurerm_app_service" "app" {
  name                = "adv001service"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.app.id

  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Server=tcp:adv001server.database.windows.net,1433;Initial Catalog=advdb;Persist Security Info=False;User ID=app-user;Password=SuperSecret!@#;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  }
}

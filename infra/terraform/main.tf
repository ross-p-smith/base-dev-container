terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.23.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "azurerm" {
  features {
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.BASE_APP_NAME}-${terraform.workspace}"
  location = var.location
  tags = {
    Deployer = var.deployer_id
    Branch   = var.branch_id
  }
}

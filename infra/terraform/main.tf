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
  name     = "rg-${var.project_name}-${terraform.workspace}"
  location = var.location
  tags = {
    Deployer = var.deployer_display_name
    Branch   = var.branch_id
  }
}

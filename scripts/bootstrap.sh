#!/bin/bash
set -euo pipefail

## This script is used to bootstrap the environment for the build process.
## This should create anything that is cross cutting; e.g. ACR, TF State Store

: "${MAKEFLAGS?'🔥 Whoa there! Script should be run from makefile, not directly silly!'}"
: "${WORKSPACE?'💥 Please define WORKSPACE in .env'}"

# Get the Azure subscription ID
arm_subscription_id=$(az account show --query id -o tsv)
mgmt_resource_group_name="rg-${TF_VAR_project_name}-mgmt"
storage_account_name="${TF_VAR_project_name}state${arm_subscription_id:24}"

# Create management resource group
az group create \
  --name "${mgmt_resource_group_name}" \
  --location "$TF_VAR_location"

# Create storage account
az storage account create \
  --resource-group "${mgmt_resource_group_name}" \
  --name "${storage_account_name}" \
  --sku Standard_LRS \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --https-only true \
  --allow-shared-key-access true

# Create container for terraform state file
az storage container-rm create \
  --storage-account "${storage_account_name}" \
  --name tfstate

# Create .tf file with the backend settings
cat >./infra/terraform/bootstrap_backend.tf <<BOOTSTRAP_BACKEND
terraform {
  backend "azurerm" {
    resource_group_name  = "${mgmt_resource_group_name}"
    storage_account_name = "${storage_account_name}"
    container_name       = "tfstate"
    key                  = "${TF_VAR_project_name}"
  }
}
BOOTSTRAP_BACKEND

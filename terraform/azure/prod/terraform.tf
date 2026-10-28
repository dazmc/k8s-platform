terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4, < 5"
    }
  }

  # Remote state: uncomment and fill in after the state storage account exists,
  # then re-run: terraform init
  # backend "azurerm" {
  #   resource_group_name  = "rg-tfstate-prod-eastus"
  #   storage_account_name = "sttfstateprodeastus"
  #   container_name       = "tfstate"
  #   key                  = "aks-prod-eastus.tfstate"
  # }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}

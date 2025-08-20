terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.1"
    }
  }
  backend "azurerm" {
    resource_group_name  = "Your RG"
    storage_account_name = "Your SA"
    container_name       = "container-name"
    key                  = "2Tier-DR.tfstate"

  }
}

provider "azurerm" {
  features {}
  subscription_id = "Your Subscription ID"
}

terraform {
  required_version = ">= 0.15"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.57"
    }
  }
}

# Configure the Azure Provider
provider "azurerm" {
  features {}
  skip_provider_registration = true
}

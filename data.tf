data "azurerm_resource_group" "rgname" {
  name = "${var.azure_system_name}-rg-${var.vm_environment}"
}

data "azurerm_subnet" "selected" {
  name                 = contains(["public"], var.vm_subnet) ? "Subnetpublic" : "Subnetprivate"
  virtual_network_name = "paas-vnet-${var.vm_environment}"
  resource_group_name  = "paas-rg-network-${var.vm_environment}"
}

data "azurerm_key_vault" "keyvault" {
  name                = "keyvaultadjooiin"
  resource_group_name = "paas-rg-network-prd"
}

data "azurerm_key_vault_secret" "keyvaultsecret" {
  name         = "AdJoinpassword"
  key_vault_id = data.azurerm_key_vault.keyvault.id
}

data "azurerm_application_security_group" "asgselected" {
  name                = "${var.azure_system_name}-asg-${var.vm_subnet}-${var.vm_environment}"
  resource_group_name = "${var.azure_system_name}-rg-${var.vm_environment}"
}

data "azurerm_application_security_group" "asgpublic" {
  name                = "${var.azure_system_name}-asg-public-${var.vm_environment}"
  resource_group_name = "${var.azure_system_name}-rg-${var.vm_environment}"
}

data "azurerm_application_security_group" "asgprivate" {
  name                = "${var.azure_system_name}-asg-private-${var.vm_environment}"
  resource_group_name = "${var.azure_system_name}-rg-${var.vm_environment}"
}
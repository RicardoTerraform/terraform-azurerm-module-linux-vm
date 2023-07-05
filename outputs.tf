output "application_security_group_id" {
  value = data.azurerm_application_security_group.asgselected.id
}

output "azure_vm_id" {
  value = local.ids
}

output "azure_vm_rg" {
  value = var.vm_old_creation ? azurerm_virtual_machine.azurevmold[0].resource_group_name : azurerm_linux_virtual_machine.vmlinux[0].resource_group_name
}

output "azure_vm_location" {
  value = var.vm_old_creation ? azurerm_virtual_machine.azurevmold[0].location : azurerm_linux_virtual_machine.vmlinux[0].location
}

output "azure_vm_name" {
  value = var.vm_old_creation ? azurerm_virtual_machine.azurevmold[0].name : azurerm_linux_virtual_machine.vmlinux[0].name
}

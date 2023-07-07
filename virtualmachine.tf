resource "azurerm_linux_virtual_machine" "vmlinux" {
  count = var.vm_old_creation ? 0 : 1

  name                  = "${var.azure_system_name}-${var.vm_name}-${var.vm_environment}"
  computer_name         = length("${var.azure_system_name}-${var.vm_name}-${var.vm_environment}") > 15 ? "${var.vm_name}" : "${var.azure_system_name}-${var.vm_name}-${var.vm_environment}"
  resource_group_name   = data.azurerm_resource_group.rgname.name
  location              = var.vm_location
  size                  = var.vm_instance_type
  network_interface_ids = [azurerm_network_interface.vm_nic.id]

  source_image_id = var.vm_image_id
  dynamic "source_image_reference" {
    for_each = var.vm_image_id == null ? ["true"] : []

    content {
      publisher = var.vm_image["publisher"]
      offer     = var.vm_image["offer"]
      sku       = var.vm_image["sku"]
      version   = var.vm_image["version"]
    }
  }

  #you are deploying a virtual machine from a Marketplace image or a custom image originating from a Marketplace image
  dynamic "plan" {
    for_each = var.vm_plan != null ? ["true"] : []
    content {
      name      = var.vm_plan["name"]
      product   = var.vm_plan["product"]
      publisher = var.vm_plan["publisher"]
    }
  }

  #availability_set_is = 
  zone = var.vm_Avail_zone_id

  #Storage account where the boot diagnostics will be saved
  boot_diagnostics {
    storage_account_uri = var.boot_diagnostics_storage_account_uri
  }

  os_disk {
    name                 = "${var.azure_system_name}-${var.vm_name}-osdisk-${var.vm_environment}"
    caching              = var.vm_os_disk_caching
    storage_account_type = var.vm_os_disk_storage_account_type
    disk_size_gb         = var.os_disk_size_gb == null ? null : split("_", var.os_disk_storage_account_type)[0] != "PremiumV2" ? [for size in local.disks_tiers[split("_", var.os_disk_storage_account_type)[0]] : size if size >= var.os_disk_size_gb][0] : var.os_disk_size_gb
  }

  #About VM Spot - we can turn it true to dev VM - sem SLA mas podemos poupar dinheiro
  priority        = var.vm_spot_instance ? "Spot" : "Regular"
  max_bid_price   = var.vm_spot_instance ? var.vm_spot_instance_max_bid_price : null
  eviction_policy = var.vm_spot_instance ? var.vm_spot_instance_eviction_policy : null

  #About update management
  patch_mode            = var.vm_patch_mode
  patch_assessment_mode = var.vm_patch_mode == "AutomaticByPlatform" ? var.vm_patch_mode : "ImageDefault"

  admin_username                  = var.vm_admin_username
  disable_password_authentication = var.vm_admin_password != null ? false : true
  admin_password                  = var.vm_admin_password
  dynamic "admin_ssh_key" {
    for_each = var.vm_ssh_public_key != null ? ["true"] : []
    content {
      public_key = var.vm_ssh_public_key
      username   = var.vm_admin_username
    }
  }

  custom_data = var.vm_custom_data ? data.template_cloudinit_config.init.rendered : null

  #Managed identity turn on - VM can access storage account/secrets/password - we do not need to expose secrets
  dynamic "identity" {
    for_each = var.vm_managed_identity != null ? ["true"] : []
    content {
      type         = var.vm_managed_identity.type
      identity_ids = var.vm_managed_identity.identity_ids
    }
  }

  tags       = merge(var.vm_tags, local.tags_default)
  depends_on = [azurerm_network_interface.vm_nic]

}

resource "azurerm_virtual_machine" "azurevmold" {
  count = var.vm_old_creation ? 1 : 0

  name                = "${var.azure_system_name}-${var.vm_name}-${var.vm_environment}"
  resource_group_name = data.azurerm_resource_group.rgname.name
  location            = var.vm_location

  vm_size               = var.vm_instance_type
  network_interface_ids = [azurerm_network_interface.vm_nic.id]

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  #availability_set_id = 

  boot_diagnostics {
    enabled     = var.boot_diagnostics_storage_account_uri != null
    storage_uri = var.boot_diagnostics_storage_account_uri
  }

  dynamic "identity" {
    for_each = var.vm_managed_identity != null ? ["true"] : []
    content {
      type         = var.vm_managed_identity.type
      identity_ids = var.vm_managed_identity.identity_ids
    }
  }

  storage_os_disk {
    name            = "${var.azure_system_name}-${var.vm_name}-osdisk-${var.vm_environment}"
    create_option   = "Attach"
    os_type         = "Linux"
    managed_disk_id = var.vm_os_disk_id
    disk_size_gb    = var.vm_os_disk_size_gb
  }

  dynamic "storage_image_reference" {
    for_each = var.vm_image_id == null ? ["true"] : []

    content {
      publisher = var.vm_image["publisher"]
      offer     = var.vm_image["offer"]
      sku       = var.vm_image["sku"]
      version   = var.vm_image["version"]
    }
  }
  ###############################################

  os_profile_linux_config {
    disable_password_authentication = var.vm_admin_password != null ? false : true
  }


  tags       = merge(var.vm_tags, local.tags_default)
  depends_on = [azurerm_network_interface.vm_nic]
}

resource "azurerm_virtual_machine_extension" "adjoin" {

  count = var.vm_join_ad ? 1 : 0

  name                       = "VMADJOIN"
  virtual_machine_id         = local.ids
  publisher                  = "Microsoft.Compute"
  type                       = "JsonADDomainExtension"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = true

  settings = <<-SETTINGS
{
 "Name": "${local.domain}",
 "Restart": "True",
 "options": "3",
 "User": "${local.join_ad_user}" 
}
SETTINGS

  protected_settings = <<-SETTINGS
{
  "Password": "${data.azurerm_key_vault_secret.keyvaultsecret.value}"
}
SETTINGS

}
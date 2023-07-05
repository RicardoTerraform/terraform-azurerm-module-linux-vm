locals {

  # This is needed since there are some features in the old resource "azurerm_virtual_machine" that are not present in the new resource "azurerm_windows_virtual_machine"
  ids = var.vm_old_creation ? azurerm_virtual_machine.azurevmold[0].id : azurerm_linux_virtual_machine.vmlinux[0].id

  domain       = "ricardocloud.pt"
  join_ad_user = "admin@ricardocloud.pt"

  #dns do ad join quando configurado
  ad_dns_server = []

  nsg_default = concat(
    var.nsg_internet ? local.internet_rules : [],
    local.ssh_rules,
    local.base_rules,
    var.vm_subnet == "private" ? local.private_asg : [],
    var.vm_subnet == "public" ? local.public_asg : []
  )

  #var.vm_subnet == "private" ? local.private_asg : local.public_asg
  internet_rules = [
    {
      name                       = "ricardo-allow-internet"
      description                = "vm can access internet"
      priority                   = 4095
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "Internet"
    }
  ]

  ssh_rules = [{
    name                   = "ricardo-allow-ssh"
    description            = "allow ssh traffic"
    priority               = 4095
    direction              = "Inbound"
    access                 = "Allow"
    protocol               = "Tcp"
    destination_port_range = "22"
    source_address_prefix  = "*"
  }]

  #ASG Public can communicate with ASG Public and ASG Private
  public_asg = [{
    name                                       = "ricardo-allow-Inbound-asg-public"
    description                                = "vm can access asg public"
    priority                                   = 4094
    direction                                  = "Inbound"
    access                                     = "Allow"
    protocol                                   = "*"
    source_port_range                          = "*"
    destination_port_range                     = "*"
    source_application_security_group_ids      = [data.azurerm_application_security_group.asgpublic.id]
    destination_application_security_group_ids = [data.azurerm_application_security_group.asgpublic.id]
    },
    {
      name                                       = "ricardo-allow-Outbound-asg-public"
      description                                = "vm can access asg public"
      priority                                   = 4094
      direction                                  = "Outbound"
      access                                     = "Allow"
      protocol                                   = "*"
      source_port_range                          = "*"
      destination_port_range                     = "*"
      source_application_security_group_ids      = [data.azurerm_application_security_group.asgpublic.id, data.azurerm_application_security_group.asgprivate.id]
      destination_application_security_group_ids = [data.azurerm_application_security_group.asgpublic.id, data.azurerm_application_security_group.asgprivate.id]
    }
  ]

  #ASG Private can only communicate with ASG Private, Can not communicate with ASG Public
  private_asg = [{
    name                                       = "ricardo-allow-Inbound-asg-private"
    description                                = "vm can access asg private"
    priority                                   = 4094
    direction                                  = "Inbound"
    access                                     = "Allow"
    protocol                                   = "*"
    source_port_range                          = "*"
    destination_port_range                     = "*"
    source_application_security_group_ids      = [data.azurerm_application_security_group.asgpublic.id, data.azurerm_application_security_group.asgprivate.id]
    destination_application_security_group_ids = [data.azurerm_application_security_group.asgprivate.id]
    },
    {
      name                                       = "ricardo-allow-Outbound-asg-private"
      description                                = "vm can access asg private"
      priority                                   = 4094
      direction                                  = "Outbound"
      access                                     = "Allow"
      protocol                                   = "*"
      source_port_range                          = "*"
      destination_port_range                     = "*"
      source_application_security_group_ids      = [data.azurerm_application_security_group.asgprivate.id]
      destination_application_security_group_ids = [data.azurerm_application_security_group.asgprivate.id]
    }
  ]

  base_rules = [
    {
      name                       = "ricardo-deny-all-inbound"
      description                = "No inbound traffic"
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "ricardo-deny-all-outbound"
      description                = "No Outbound traffic"
      priority                   = 4096
      direction                  = "Outbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]

  tags_default = {
    system         = lower(var.azure_system_name)
    environment    = lower(var.vm_environment)
    infrastructure = "terraform"
    module         = "azurerm-linux-vm"
    module_version = "v1.0"
  }
}

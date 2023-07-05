resource "azurerm_network_interface" "vm_nic" {
  name                          = "${var.azure_system_name}-${var.vm_name}-nic-${var.vm_environment}"
  location                      = var.vm_location
  resource_group_name           = data.azurerm_resource_group.rgname.name
  enable_accelerated_networking = var.vm_nic_enable_accelerated_networking
  dns_servers                   = local.ad_dns_server
  ip_configuration {
    name                          = "${var.azure_system_name}-${var.vm_name}-nic-ipconfig-${var.vm_environment}"
    subnet_id                     = var.vm_subnet_id == null ? data.azurerm_subnet.selected.id : var.vm_subnet_id
    private_ip_address_allocation = var.vm_private_ip_allocation == null ? "Dynamic" : "Static"
    private_ip_address            = var.vm_private_ip_allocation == "Static" ? var.vm_static_private_ip : null
    public_ip_address_id          = var.vm_public_ip_created == false ? null : element(azurerm_public_ip.vm_public_ip[*].id, 0)
    private_ip_address_version    = var.vm_private_ip_address_version
  }
  tags       = merge(var.vm_tags, local.tags_default)
  depends_on = [module.newrg]
}

resource "azurerm_public_ip" "vm_public_ip" {
  count = var.vm_public_ip_created == false ? 0 : 1

  name                = "${var.azure_system_name}-${var.vm_name}-nic-pub-${var.vm_environment}"
  location            = var.vm_location
  resource_group_name = data.azurerm_resource_group.rgname.name
  allocation_method   = "Static"

  sku        = var.vm_public_ip_sku
  zones      = var.vm_public_ip_zones
  depends_on = [module.newrg]

  tags = merge(var.vm_tags, local.tags_default)
}

### ASG
resource "azurerm_network_interface_application_security_group_association" "asg" {
  network_interface_id          = azurerm_network_interface.vm_nic.id
  application_security_group_id = var.vm_application_security_group_id == null ? data.azurerm_application_security_group.asgselected.id : var.vm_application_security_group_id
}


### NSG
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.azure_system_name}-${var.vm_name}-nsg-${var.vm_environment}"
  location            = var.vm_location
  resource_group_name = "${var.azure_system_name}-rg-${var.vm_environment}"

  tags       = merge(var.vm_tags, local.tags_default)
  depends_on = [module.newrg]
}

resource "azurerm_network_interface_security_group_association" "nsg" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id

  depends_on = [azurerm_network_interface.vm_nic,
  azurerm_network_security_group.nsg]
}


resource "azurerm_network_security_rule" "nsgrules" {
  count = length(local.nsg_default)

  name                                       = lookup(local.nsg_default[count.index], "name")
  description                                = lookup(local.nsg_default[count.index], "description", "")
  priority                                   = lookup(local.nsg_default[count.index], "priority")
  direction                                  = lookup(local.nsg_default[count.index], "direction", "Outbound")
  access                                     = lookup(local.nsg_default[count.index], "access", "Allow")
  protocol                                   = lookup(local.nsg_default[count.index], "protocol", "Tcp")
  source_port_range                          = lookup(local.nsg_default[count.index], "source_port_range", null)
  source_port_ranges                         = lookup(local.nsg_default[count.index], "source_port_range", null) == null && lookup(local.nsg_default[count.index], "source_port_ranges", null) == null ? ["0-65535"] : lookup(local.nsg_default[count.index], "source_port_range", null) == null ? lookup(local.nsg_default[count.index], "source_port_ranges") : null
  destination_port_range                     = lookup(local.nsg_default[count.index], "destination_port_range", null)
  destination_port_ranges                    = lookup(local.nsg_default[count.index], "destination_port_range", null) == null && lookup(local.nsg_default[count.index], "destination_port_ranges", null) == null ? ["0-65535"] : lookup(local.nsg_default[count.index], "destination_port_range", null) == null ? lookup(local.nsg_default[count.index], "destination_port_ranges") : null
  source_address_prefix                      = lookup(local.nsg_default[count.index], "source_address_prefix", null) == null && lookup(local.nsg_default[count.index], "source_application_security_group_ids", null) == null && lookup(local.nsg_default[count.index], "source_address_prefixes", null) == null ? "*" : lookup(local.nsg_default[count.index], "source_address_prefixes", null) == null && lookup(local.nsg_default[count.index], "source_application_security_group_ids", null) == null ? lookup(local.nsg_default[count.index], "source_address_prefix") : null
  source_address_prefixes                    = lookup(local.nsg_default[count.index], "source_application_security_group_ids", null) == null ? lookup(local.nsg_default[count.index], "source_address_prefixes", null) : null
  destination_address_prefix                 = lookup(local.nsg_default[count.index], "destination_address_prefix", null) == null && lookup(local.nsg_default[count.index], "destination_application_security_group_ids", null) == null && lookup(local.nsg_default[count.index], "destination_address_prefixes", null) == null ? "*" : lookup(local.nsg_default[count.index], "destination_address_prefixes", null) == null && lookup(local.nsg_default[count.index], "destination_application_security_group_ids", null) == null ? lookup(local.nsg_default[count.index], "destination_address_prefix") : null
  destination_address_prefixes               = lookup(local.nsg_default[count.index], "destination_application_security_group_ids", null) == null ? lookup(local.nsg_default[count.index], "destination_address_prefixes", null) : null
  source_application_security_group_ids      = lookup(local.nsg_default[count.index], "source_application_security_group_ids", null)
  destination_application_security_group_ids = lookup(local.nsg_default[count.index], "destination_application_security_group_ids", null)
  resource_group_name                        = data.azurerm_resource_group.rgname.name
  network_security_group_name                = azurerm_network_security_group.nsg.name

  depends_on = [azurerm_network_security_group.nsg]
}

resource "azurerm_network_security_rule" "nsgcustomrules" {
  count = length(var.nsg_customrules)

  name                                       = lookup(var.nsg_customrules[count.index], "name", "default-name-nsg")
  description                                = lookup(var.nsg_customrules[count.index], "description", "")
  priority                                   = lookup(var.nsg_customrules[count.index], "priority", (4090 - 100 * (count.index)))
  direction                                  = lookup(var.nsg_customrules[count.index], "direction", "Inbound")
  access                                     = lookup(var.nsg_customrules[count.index], "access", "Allow")
  protocol                                   = lookup(var.nsg_customrules[count.index], "protocol", "*")
  source_port_range                          = lookup(var.nsg_customrules[count.index], "source_port_range", null)
  source_port_ranges                         = lookup(var.nsg_customrules[count.index], "source_port_range", null) == null && lookup(local.nsg_default[count.index], "source_port_ranges", null) == null ? ["0-65535"] : lookup(local.nsg_default[count.index], "source_port_range", null) == null ? lookup(local.nsg_default[count.index], "source_port_ranges") : null
  destination_port_range                     = lookup(var.nsg_customrules[count.index], "destination_port_range", null)
  destination_port_ranges                    = lookup(var.nsg_customrules[count.index], "destination_port_range", null) == null && lookup(local.nsg_default[count.index], "destination_port_ranges", null) == null ? ["0-65535"] : lookup(local.nsg_default[count.index], "destination_port_range", null) == null ? lookup(local.nsg_default[count.index], "destination_port_ranges") : null
  source_address_prefix                      = lookup(var.nsg_customrules[count.index], "source_address_prefix", null) == null && lookup(local.nsg_default[count.index], "source_application_security_group_ids", null) == null && lookup(local.nsg_default[count.index], "source_address_prefixes", null) == null ? "*" : lookup(local.nsg_default[count.index], "source_address_prefixes", null) == null && lookup(local.nsg_default[count.index], "source_application_security_group_ids", null) == null ? lookup(local.nsg_default[count.index], "source_address_prefix") : null
  source_address_prefixes                    = lookup(var.nsg_customrules[count.index], "source_application_security_group_ids", null) == null ? lookup(local.nsg_default[count.index], "source_address_prefixes", null) : null
  destination_address_prefix                 = lookup(var.nsg_customrules[count.index], "destination_address_prefix", null) == null && lookup(local.nsg_default[count.index], "destination_application_security_group_ids", null) == null && lookup(local.nsg_default[count.index], "destination_address_prefixes", null) == null ? "*" : lookup(local.nsg_default[count.index], "destination_address_prefixes", null) == null && lookup(local.nsg_default[count.index], "destination_application_security_group_ids", null) == null ? lookup(local.nsg_default[count.index], "destination_address_prefix") : null
  destination_address_prefixes               = lookup(var.nsg_customrules[count.index], "destination_application_security_group_ids", null) == null ? lookup(local.nsg_default[count.index], "destination_address_prefixes", null) : null
  source_application_security_group_ids      = lookup(var.nsg_customrules[count.index], "source_application_security_group_ids", null)
  destination_application_security_group_ids = lookup(var.nsg_customrules[count.index], "destination_application_security_group_ids", null)
  resource_group_name                        = data.azurerm_resource_group.rgname.name
  network_security_group_name                = azurerm_network_security_group.nsg.name

  depends_on = [azurerm_network_security_group.nsg]
}
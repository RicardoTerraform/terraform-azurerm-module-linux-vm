variable "vm_name" {
  type        = string
  description = "This defines the name of the VM"
}

variable "azure_system_name" {
  type        = string
  description = "This defines the system of the resource"
}

variable "vm_environment" {
  type        = string
  description = "This defines the environment of the resource. two options: dev | prd"
  default     = "dev"
}

variable "vm_location" {
  type        = string
  description = "This defines the location of the resource"
  default     = "westeurope"
}

variable "vm_tags" {
  type        = map(any)
  description = "Tags to put on resources"
  default     = {}
}

variable "vm_old_creation" {
  type        = bool
  description = "This is needed since there are some features in the old resource azurerm_virtual_machine(true) that are not present in the new resource azurerm_windows_virtual_machine(false)"
  default     = false
}

variable "vm_instance_type" {
  type        = string
  description = "VM instance type."
  default     = "Standard_B2s"
}

variable "vm_image_id" {
  type        = string
  description = "The ID of the Image which this Virtual Machine should be created from. This variable cannot be used if `vm_image` is already defined."
  default     = null
}

variable "vm_plan" {
  type = object({
    name      = string
    product   = string
    publisher = string
  })
  description = "Virtual Machine plan image information. See https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine#plan. This variable has to be used for BYOS image. Before using BYOS image, you need to accept legal plan terms. See https://docs.microsoft.com/en-us/cli/azure/vm/image?view=azure-cli-latest#az_vm_image_accept_terms."
  default = null
}

#az vm image list
variable "vm_image" {
  type        = map(string)
  description = "Virtual Machine source image information. See https://www.terraform.io/docs/providers/azurerm/r/virtual_machine.html#storage_image_reference. This variable cannot be used if `vm_image_id` is already defined."
  default = {
    publisher = "canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

variable "vm_Avail_zone_id" {
  type        = number
  description = "Index of the Availability Zone which the Virtual Machine should be allocated in."
  default     = null
}


variable "vm_subnet_id" {
  type        = string
  description = "ID of the Subnet in which create the Virtual Machine"
  default     = null

}
variable "vm_subnet" {
  type        = string
  description = "Subnet where VM will be created. (public | private)"
  default     = "private"
}

variable "vm_private_ip_allocation" {
  type        = string
  description = "Private IP allocation. Private IP is dynamic if not set. Dynamic | Static"
  default     = null
}

variable "vm_static_private_ip" {
  type        = string
  description = "Static private IP. Define the static IP address for that VM."
  default     = null
}

variable "vm_public_ip_created" {
  type        = bool
  description = "Is a Pulic IP  to be created? Public IP is False if not set"
  default     = false
}

variable "vm_public_ip_sku" {
  description = "SKU for the public IP attached to the VM. Can be `null` if no public IP needed."
  type        = string
  default     = "Standard"
}

variable "vm_public_ip_zones" {
  description = "Zones for public IP attached to the VM. Can be `null` if no zone distpatch."
  type        = list(number)
  default     = [1, 2, 3]
}

variable "vm_private_ip_address_version" {
  type        = string
  description = "The IP Version to use. Possible values are IPv4 or IPv6. Defaults to IPv4"
  default     = "IPv4"
}

variable "vm_nic_enable_accelerated_networking" {
  type        = bool
  description = "Should Accelerated Networking be enabled? Defaults to `false`."
  default     = false
}

variable "boot_diagnostics_storage_account_uri" {
  type        = string
  description = "Storage account where the boot diagnostics will be saved. Passing a null value will utilize a Managed Storage Account to store Boot Diagnostics"
  default     = null
}

variable "vm_managed_identity" {
  type = object({
    type         = string
    identity_ids = list(string)
  })
  description = "Map with identity block informations as described here https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine#identity"
  default = {
    type         = "SystemAssigned"
    identity_ids = []
  }
}

variable "vm_os_disk_caching" {
  type        = string
  description = "Specifies the caching requirements for the OS Disk (None | ReadOnly | ReadWrite)"
  default     = "ReadWrite"
}

variable "vm_os_disk_storage_account_type" {
  type        = string
  description = "The Type of Storage Account which should back this the Internal OS Disk. Possible values are (`Standard_LRS` | `StandardSSD_LRS` | `Premium_LRS` | `StandardSSD_ZRS` | `Premium_ZRS`)"
  default     = "Premium_ZRS"
}

variable "vm_os_disk_size_gb" {
  type        = string
  description = "Specifies the size of the OS disk in gigabytes"
  default     = null
}

variable "vm_os_disk_id" {
  type        = string
  description = "ID of the disk to attach as the OS Disk"
  default     = null
}

variable "vm_spot_instance" {
  type        = bool
  description = "True to deploy VM as a Spot Instance"
  default     = false
}

variable "vm_spot_instance_max_bid_price" {
  type        = number
  description = "The maximum price you're willing to pay for this VM in US Dollars; must be greater than the current spot price. `-1` If you don't want the VM to be evicted for price reasons."
  default     = -1
}

variable "vm_spot_instance_eviction_policy" {
  type        = string
  description = "Specifies what should happen when the Virtual Machine is evicted for price reasons when using a Spot instance. At this time the only supported value is `Deallocate`. Changing this forces a new resource to be created."
  default     = "Deallocate"
}

variable "vm_patch_mode" {
  type        = string
  description = "Specifies the mode of in-guest patching to this Linux Virtual Machine. Possible values are  AutomaticByPlatform | ImageDefault"
  default     = "ImageDefault"
}

variable "vm_admin_username" {
  type        = string
  description = "Username for Virtual Machine administrator account"
  default     = "cloud-admin"
}

variable "vm_admin_password" {
  type        = string
  description = "Password for the administrator account of the virtual machine."
  default     = null
}

variable "vm_ssh_public_key" {
  type        = string
  description = "SSH public key"
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDvV5bPjf/dWciHFE2gk0v/5r28QpEFwii9HjD25dOzwkV+2QHY/+aE9JU9dFoOLOpYrDcRWavRehb6NsoBgASX7vqKjI3DPJoD5eyd+qxfr1spjhVrcSzbMT8aUWzXR1AZk/HpbU8Qgk6/ZYE7LNXGtFImuwbWNcN0ddLIh0LLfgu2Y+gZ78XcqxF8tFJRj1gPR8f40LUXqkRK1SK/eUpVtHAnxnJIW+Sjp+nppEHI9/KMGOUnKTE+N1wtpO4FLz2gS+TBLjvPuPxUK60c1+ovjpF9Bw/jSQftvNaUbwIvxFA9rhWVDYbsdWVpfQK3ljaXJ9HHwKmAGbqsz/zsF9D2+FYmnJrHsLbg3iN4O4pdZNI9tMWte18v7YsihAMyditcGAVkOXIamwKcMtGTeWHqGS5Vub8Zftj50xXVN8N2epE8VNPmrz+YvhTnin/8LAOfu6+77+rUndtOh1DnCDnQW1sWXtVUuRZ9u10i54UEhigQ5q11bsjeuOfMTPhTTrp91wgC5+iAwpNwY1Ybu1/U0YXIFua8CTbwT+aHQtHhgVa814eGabHiVfFMbt320756B5Py/HKQQLD2kWVtrpRpvM5k1wTCS6AcJl3y7fPfGgwm4gun4EA4D+opCQrajvAyW98Db7Yi+GWQ3rtOthIg8CrXrEHzKlCiXEdHjGDMfw=="
}

variable "vm_join_ad" {
  type        = bool
  description = "Join this VM to the AD ?"
  default     = false
}

variable "vm_application_security_group_id" {
  type        = string
  description = "ASG ID from an existing Application Security group"
  default     = null
}

variable "nsg_internet" {
  type        = bool
  description = "Allow Internet connection inside the instance?"
  default     = true
}

variable "nsg_customrules" {
  type = list(object({
    name                         = string
    description                  = string
    priority                     = number
    direction                    = string
    access                       = string
    protocol                     = string
    source_port_range            = string
    source_port_ranges           = list(string)
    destination_port_range       = string
    destination_port_ranges      = list(string)
    source_address_prefix        = string
    source_address_prefixes      = list(string)
    destination_address_prefix   = string
    destination_address_prefixes = list(string)
  }))
  description = "Security rules for the network security group using this format name = [name, description, priority, direction, access, protocol, source_port_range, destination_port_range, source_address_prefix, destination_address_prefix]"
  default     = []
}

variable "vm_custom_data" {
  type        = bool
  description = "Is there any Bash script to run during the provisioning?"
  default     = false
}

variable "vm_custom_data_script" {
  type        = list(string)
  description = "what´s the script name? ex: 'createfolder.sh', upload the script to the repository | This variable cannot be used if `vm_custom_data` is 'false'."
  default     = []
}

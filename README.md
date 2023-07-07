# terraform-azurerm-module-linux-vm

# Requirements
No requirements

# Providers
| Name          | Version       |
| ------------- | ------------- |
| azurerm       | n/a           |
| template      | n/a           |

# Modules
No Modules

# Resources
| Name                                            | type               |
| ----------------------------------------------- | ------------------ |
| azurerm_linux_virtual_machine.vmlinux | resource |
| azurerm_network_interface.vm_nic                      | resource           |
| azurerm_network_interface_application_security_group_association.asg  | resource |
| azurerm_network_interface_security_group_association.nsg | resource           |
| azurerm_network_security_group.nsg     | resource           |
| azurerm_network_security_rule.nsgrules| resource        |
| azurerm_network_security_rule.nsgcustomrules | resource |
| azurerm_public_ip.vm_public_ip | resouce |
| azurerm_virtual_machine.azurevmold | resource |
| azurerm_virtual_machine_extension.adjoin | resource |
| azurerm_application_security_group.asgprivate | data source |
| azurerm_application_security_group.asgpublic | data source |
| azurerm_application_security_group.asgselected | data source |
| azurerm_key_vault.keyvault | data source |
| azurerm_key_vault_secret.keyvaultsecret | data source |
| azurerm_resource_group.rgname | data source |
| azurerm_subnet.selected | data source |
| template_cloudinit_config.init | data souce |




# Inputs
| Name                 | Description                                  |  type          | Default                                                    |  Required  |
| -------------------- | -------------------------------------------- | -------------- | ---------------------------------------------------------  | ---------- |
| azure_system_name    | The system name, e.g catalog                 | string         | n/a                                                        | yes        |
| vm_name              | This defines the name of the VM              | string         | n/a                                                        | yes        |
| vm_environment       | Environment tag, e.g prd                     | string         | n/a                                                        | yes        |
| boot_diagnostics_storage_account_uri | Storage account where the boot diagnostics will be saved. Passing a null value will utilize a Managed Storage Account to store Boot Diagnostics | string | null | no |
| nsg_customrules | Security rules for the network security group using this format name = [name, description, priority, direction, access, protocol, source_port_range, destination_port_range, source_address_prefix, destination_address_prefix] | <pre>list(object({<br> name  = string<br> description = string <br> priority = number <br> direction  = string <br> access = string <br> protocol = string <br> source_port_range = string <br> source_port_ranges = list(string) <br> destination_port_range = string <br> destination_port_ranges = list(string) <br> source_address_prefix = string <br> source_address_prefixes = list(string) <br> destination_address_prefix = string <br> destination_address_prefixes = list(string) <br>}))</pre> | [] | no |
| nsg_internet | Allow Internet connection inside the instance? | bool | true | no |
| vm_admin_password | Password for the administrator account of the virtual machine | string | null | no |
| vm_admin_username | Username for Virtual Machine administrator account | string | cloud-admin | no |
| vm_application_security_group_id | ASG ID from an existing Application Security group | string | null | no |
| vm_Avail_zone_id     | Index of the Availability Zone which the Virtual Machine should be allocated in | number    | null                         | no         |
| vm_custom_data | Is there Any extra script to be ran? if yes, upload the script to the repository  | bool | false | no |
| vm_custom_data_script | what´s the script name? ex: 'createfolder.ps1', upload the script to the repository / This variable cannot be used if 'vm_custom_script' is 'false'. | list(string) | [] | no
| vm_image             | "Virtual Machine source image information. See https://www.terraform.io/docs/providers/azurerm/r/virtual_machine.html#storage_image_reference. This variable cannot be used if `vm_image_id` is already defined." | map(string)   | <pre>object({<br> publisher = "canonical"<br> offer     = "UbuntuServer" <br> sku       = "18.04-LTS" <br> version   = "latest" <br>})</pre> | no         |
| vm_image_id          | The ID of the Image which this Virtual Machine should be created from. This variable cannot be used if `vm_image` is already defined | string         | null  | no         |
| vm_instance_type     | VM instance type                             | string         | "Standard_B2s"                                             | no         |
| vm_join_ad | Join this VM to the AD ? | bool | false | no |
| vm_location          | This defines the location of the resource    | string         | "westeurope"                                               | no         |
| vm_managed_identity | Map with identity block informations as described here https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine#identity | <pre>object({<br> type         = string <br> identity_ids = list(string) <br>})</pre> | <pre>{<br> type = "SystemAssigned" <br> identity_ids = [] <br>}</pre> | no
| vm_nic_enable_accelerated_networking | Should Accelerated Networking be enabled? Defaults to `false` | bool | false | no |
| vm_old_creation  | This is needed since there are some features in the old resource azurerm_virtual_machine(true) that are not present in the new resource azurerm_windows_virtual_machine(false) | bool   | false | no| 
| vm_os_disk_id | ID of the disk to attach as the OS Disk | string | null | no | 
| vm_os_disk_size_gb | Specifies the size of the OS disk in gigabytes | string | null | no |
| vm_os_disk_caching | Specifies the caching requirements for the OS Disk (None / ReadOnly / ReadWrite) | string | null | no |
| vm_os_disk_storage_account_type | The Type of Storage Account which should back this the Internal OS Disk. Possible values are (`Standard_LRS` / `StandardSSD_LRS` / `Premium_LRS` / `StandardSSD_ZRS` / `Premium_ZRS`) | string | "Premium_ZRS" | no |
| vm_patch_mode | Specifies the mode of in-guest patching to this Linux Virtual Machine. Possible values are  AutomaticByPlatform / ImageDefault | string | "ImageDefault" | no |
| vm_plan | Virtual Machine plan image information. you are deploying a virtual machine from a Marketplace image or a custom image originating from a Marketplace image | <pre>object({<br> name  = string <br> product   = string <br> publisher = string <br>})</pre>|null | no
| vm_private_ip_address_version | The IP Version to use. Possible values are IPv4 or IPv6. Defaults to IPv4 | string | "IPv4" | no |
|vm_private_ip_allocation| Private IP allocation. Private IP is dynamic if not set. Dynamic / Static | string   | null | no         |
| vm_public_ip_created          | Is a Pulic IP  to be created? Public IP is False if not set | bool   | false | no         |
| vm_public_ip_sku | SKU for the public IP attached to the VM. Can be `null` if no public IP needed | string | "Standard" | no |
| vm_public_ip_zones | Zones for public IP attached to the VM. Can be `null` if no zone distpatch | list(number) | [1, 2, 3] | no |
| vm_spot_instance | True to deploy VM as a Spot Instance | bool | false | no |
| vm_spot_instance_max_bid_price | The maximum price you're willing to pay for this VM in US Dollars; must be greater than the current spot price. `-1` If you don't want the VM to be evicted for price reasons | number | -1 | no |
| vm_spot_instance_eviction_policy | Specifies what should happen when the Virtual Machine is evicted for price reasons when using a Spot instance. At this time the only supported value is `Deallocate`. Changing this forces a new resource to be created | string | "Deallocate" | no |
| vm_ssh_public_key | SSH public key | string | "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDvV5bPjf/dWciHFE2gk0v/5r28QpEFwii9HjD25dOzwkV+2QHY/ +aE9JU9dFoOLOpYrDcRWavRehb6NsoBgASX7vqKjI3DPJoD5eyd+qxfr1spjhVrcSzbMT8aUWzXR1AZk/HpbU8Qgk6/ZYE7LNXGtFImuwbWNcN0ddLIh0LLfgu2Y+gZ78XcqxF8tFJ Rj1gPR8f40LUXqkRK1SK/eUpVtHAnxnJIW+Sjp+nppEHI9/KMGOUnKTE+N1wtpO4FLz2gS+TBLjvPuPxUK60c1+ovjpF9Bw/jSQftvNaUbwIvxFA9rhWVDYbsdWVpfQK3ljaXJ9HHw KmAGbqsz/zsF9D2+FYmnJrHsLbg3iN4O4pdZNI9tMWte18v7YsihAMyditcGAVkOXIamwKcMtGTeWHqGS5Vub8Zftj50xXVN8N2epE8VNPmrz+YvhTnin/8LAOfu6+77+rUndtOh1D nCDnQW1sWXtVUuRZ9u10i54UEhigQ5q11bsjeuOfMTPhTTrp91wgC5+iAwpNwY1Ybu1/U0YXIFua8CTbwT+aHQtHhgVa814eGabHiVfFMbt320756B5Py/HKQQLD2kWVtrpRpvM5k1 wTCS6AcJl3y7fPfGgwm4gun4EA4D+opCQrajvAyW98Db7Yi+GWQ3rtOthIg8CrXrEHzKlCiXEdHjGDMfw==" | no |
| vm_static_private_ip          | UStatic private IP. Define the static IP address for that VM | string   | null | no         |
| vm_subnet            | Subnet where VM will be created. (public / private) | string   | "private"                                                 | no         |
| vm_subnet_id         | ID of the Subnet in which create the Virtual Machine | string  | null                                                      | no         |
| vm_tags              | Tags to put on resources                     | map(any)       | {}                                                         | no         |





# Outputs
| Name                           | Description   |
| ------------------------------ | ------------- |
| application_security_group_id  | n/a           |
| azure_vm_id                    | n/a           |
| azure_vm_rg                    | n/a           |
| azure_vm_location              | n/a           |
| azure_vm_name                  | n/a           |


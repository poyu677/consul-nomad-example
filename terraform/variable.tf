variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "resource_group_location" {
  type        = string
  description = "Resource group location"
  default     = "Japan East"
}

variable "vm_admin_name" {
  type        = string
  description = "Admin name of VMs"
  default     = "azureuser"
}

variable "vm_public_key_from" {
  type        = string
  description = "Your public key path to login to vms"
  default     = "~/.ssh/id_rsa.pub"
}

variable "default_vm_size" {
  type        = string
  description = "VM's size"
  default     = "Standard_B1ls"
}

variable "default_worker_vm_size" {
  type        = string
  description = "nomad worker VM's size"
  default     = "Standard_D2_v4"
}

variable "consul_vm_name" {
  type        = string
  description = "consul vm's host name"
  default     = "consul"
}

variable "nomad_vm_name" {
  type        = string
  description = "nomad server vm's host name"
  default     = "nomad-server"
}

variable "nomad_client_vm_name" {
  type        = string
  description = "nomad client vm's host name"
  default     = "nomad-client"
}

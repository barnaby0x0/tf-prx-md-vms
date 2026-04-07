# Proxmox connection object
# variable "proxmox_connection" {
#   description = "Proxmox connection info (url, token)"
#   type = object({
#     proxmox_url = string
#     api_token   = string
#   })
# }

variable "proxmox_url" {
  type = string
}

variable "api_token" {
  type = string
}

variable "target_node" {
  description = "Proxmox node"
  type        = string
  default     = "pve"
}

# variable "vm_configs_dir" {
#   description = "Vm Configuration directory"
#   type        = string
#   default     = "vm_configs"
# }

variable "http_server_url" {
  description = "The http server ip"
  type        = string
  default     = "192.168.1.31:8080"
}

variable "vm_definitions" {
  description = "A list of yaml files that define a vm."
  type        = list(string)
}
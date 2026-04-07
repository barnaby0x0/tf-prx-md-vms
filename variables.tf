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

variable "http_server_url" {
  description = "The http server ip"
  type        = string
  default     = "192.168.1.31:8080"
}

variable "vm_definitions" {
  description = "A list of yaml files that define a vm."
  type        = list(string)
}
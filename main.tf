terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.96.0"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_url
  api_token = var.api_token
  insecure  = true
  ssh {
    agent       = false
    username    = "root"
    private_key = file("~/.ssh/id_ed25519")
  }
}

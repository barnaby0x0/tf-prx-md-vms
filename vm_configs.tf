locals {
  vm_configs = flatten([
    for content in var.vm_definitions : [
      yamldecode(
        base64decode(content)
      )
    ]
  ])
}

module "config" {
  #source     = "../definitions"
  source = "git::https://github.com/barnaby0x0/tf-prx-md-defs.git?ref=v0.1"
  vm_configs = local.vm_configs
}

locals {
  configs = module.config.vm_configs
}

output "name" {
  value = local.configs
}
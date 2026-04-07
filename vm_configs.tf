# locals {
#   vm_configs = flatten([
#     for file in fileset(var.vm_configs_dir, "*.yaml") : [
#       yamldecode(templatefile("${var.vm_configs_dir}/${file}", {
#         http_server_url = var.http_server_url
#       }))
#     ]
#   ])
# }

# locals {
#   vm_configs = flatten([
#     for content in var.vm_definitions : [
#       yamldecode(templatestring(content, {
#         http_server_url = var.http_server_url
#       }))
#     ]
#   ])
# }

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
  source     = "../definitions"
  vm_configs = local.vm_configs
}

locals {
  configs = module.config.vm_configs
}

output "name" {
  value = local.configs
}
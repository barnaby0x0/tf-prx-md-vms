resource "proxmox_virtual_environment_file" "cloud_user_config" {
  for_each     = { for vm in local.configs : vm.id => vm if vm.deploy && vm.enable_cloud_init }
  content_type = "snippets"
  datastore_id = "snippets"
  node_name    = var.target_node

  source_raw {
    data = templatefile("${path.module}/${each.value.cloudinit_templates.user_data_path}", {
      users    = each.value.users
      files    = each.value.files
      cmds     = each.value.cmds
      hostname = coalesce(each.value.hostname, null)
    })
    file_name = "${each.value.hostname}-ci-user.yml"
  }
}

resource "proxmox_virtual_environment_file" "cloud_network_config" {
  for_each = { for vm in local.configs : vm.id => vm if vm.deploy && vm.enable_cloud_init }

  content_type = "snippets"
  datastore_id = "snippets"
  node_name    = var.target_node

  source_raw {
    data = templatefile("${path.module}/${each.value.cloudinit_templates.network_path}", {
      nics        = each.value.network_devices
      dns_servers = format("[%s]", join(", ", [for s in each.value.dns_servers : "\"${s}\""]))
    })
    file_name = "${each.value.hostname}-ci-network.yml"
  }

}

resource "proxmox_virtual_environment_file" "cloud_meta_config" {
  for_each     = { for vm in local.configs : vm.id => vm if vm.deploy && vm.enable_cloud_init }
  content_type = "snippets"
  datastore_id = "snippets"
  node_name    = var.target_node

  source_raw {
    data = templatefile("${path.module}/${each.value.cloudinit_templates.meta_data}", {
        instance_id    = sha1(each.value.hostname)
        local_hostname = each.value.hostname
      }
    )

    file_name = "${each.value.hostname}.${each.value.domain}-ci-meta_data.yml"
  }
}

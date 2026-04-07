resource "proxmox_virtual_environment_vm" "vm" {
  for_each = { for vm in local.configs : vm.id => vm if vm.deploy }

  vm_id     = each.value.vm_id
  name      = "${each.value.hostname}.${each.value.domain}"
  node_name = each.value.target_node

  on_boot = each.value.onboot
  started = each.value.started

  dynamic "agent" {
    for_each = each.value.agent ? [1] : []
    content {
      enabled = each.value.agent
    }
  }

  dynamic "clone" {
    for_each = each.value.template_id != null ? [1] : []
    content {
      vm_id = each.value.template_id
    }
  }

  bios = each.value.bios
  dynamic "efi_disk" {
    for_each = each.value.efi_disk != null ? [each.value.efi_disk] : []
    content {
      datastore_id      = efi_disk.value.datastore_id
      file_format       = efi_disk.value.file_format
      type              = efi_disk.value.type
      pre_enrolled_keys = efi_disk.value.pre_enrolled_keys
    }
  }
  boot_order = each.value.boot_order

  dynamic "cdrom" {
    for_each = each.value.cdrom != null ? [each.value.cdrom] : []
    content {
      file_id = cdrom.value.file_id
    }
  }

  tags = each.value.vm_tags
  cpu {
    type    = each.value.cpu_type
    cores   = each.value.cpu_cores
    sockets = each.value.cpu_sockets
    flags   = []
  }

  memory { dedicated = each.value.memory }

  dynamic "network_device" {
    for_each = each.value.network_devices
    content {
      bridge   = network_device.value.bridge
      model    = network_device.value.model
      firewall = network_device.value.firewall
    }
  }

  lifecycle {
    ignore_changes = [
      network_device,
    ]
  }

  scsi_hardware = "virtio-scsi-single"

  dynamic "disk" {
    for_each = each.value.disks
    content {
      interface    = disk.value.interface
      iothread     = disk.value.iothread
      datastore_id = disk.value.storage
      size         = disk.value.size
      discard      = disk.value.discard
    }
  }

  dynamic "startup" {
    for_each = try(each.value.startup, null) == null ? [] : [each.value.startup]

    content {
      order      = startup.value.order
      up_delay   = startup.value.up_delay
      down_delay = startup.value.down_delay
    }
  }

  dynamic "initialization" {
    for_each = each.value.enable_cloud_init ? [1] : []
    content {
      datastore_id         = "local-lvm"
      interface            = "ide2"
      user_data_file_id    = proxmox_virtual_environment_file.cloud_user_config[each.key].id
      meta_data_file_id    = proxmox_virtual_environment_file.cloud_meta_config[each.key].id
      network_data_file_id = proxmox_virtual_environment_file.cloud_network_config[each.key].id
    }
  }
}

resource "proxmox_virtual_environment_firewall_options" "vm_firewall" {
  for_each = { for vm in local.configs : vm.id => vm if vm.deploy && vm.firewall_enabled }

  node_name = each.value.target_node
  vm_id     = proxmox_virtual_environment_vm.vm[each.key].id

  enabled       = true
  dhcp          = true
  input_policy  = "DROP"
  output_policy = "DROP"
  log_level_in  = "nolog"
  ndp           = true
  ipfilter      = false

  depends_on = [
    proxmox_virtual_environment_vm.vm
  ]
}

resource "proxmox_virtual_environment_firewall_rules" "inbound" {
  for_each = { for vm in local.configs : vm.id => vm if vm.deploy && vm.firewall_enabled }
  depends_on = [
    proxmox_virtual_environment_vm.vm
  ]

  node_name = each.value.target_node
  vm_id     = proxmox_virtual_environment_vm.vm[each.key].id

  dynamic "rule" {
    for_each = try(each.value.fw_rules, null) == null ? [] : each.value.fw_rules
    content {
      # security_group = rule.value.security_group
      comment = rule.value.comment
      iface   = rule.value.iface
      type    = rule.value.type
      action  = rule.value.action
      # action  = try(rule.value.action, null) == null ? null : rule.value.action
      enabled = rule.value.enabled
      dest    = rule.value.dest
      dport   = rule.value.dport
      proto   = rule.value.proto
      log     = rule.value.log
      source  = rule.value.source
      sport   = rule.value.sport
      macro   = rule.value.macro
    }
  }

  dynamic "rule" {
    for_each = try(each.value.secgroups, null) == null ? [] : each.value.secgroups
    content {
      security_group = rule.value.security_group
      comment        = rule.value.comment
      iface          = rule.value.iface
      enabled        = rule.value.enabled
    }
  }

  # rule {
  #   type    = "in"
  #   action  = "ACCEPT"
  #   comment = "Allow HTTP"
  #   dest    = "192.168.1.5"
  #   dport   = "80"
  #   proto   = "tcp"
  #   log     = "info"
  # }

}

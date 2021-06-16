output "hostname_list" {
  value = join(",", alicloud_instance.instance.*.instance_name)
}

output "ecs_ids" {
  value = join(",", alicloud_instance.instance.*.id)
}

output "eip_addresses" {
  value = join(",", alicloud_eip.eip.*.ip_address)


}


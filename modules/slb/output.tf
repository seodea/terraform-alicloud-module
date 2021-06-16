output "sg_info" {
  value = alicloud_slb.slb_instance.*.id

}

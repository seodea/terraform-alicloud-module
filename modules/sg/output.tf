output "sg_id" {
  value = alicloud_security_group.main_sg.id

}

#output "private_sg_id" {
#  value = alicloud_security_group.private_sg.id
#
#}

#output "temp" {
#   value = length(var.ingress_with_cidr_blocks_and_ports)
#
#}

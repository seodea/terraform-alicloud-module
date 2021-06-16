output "public_sg_id" {
  value = alicloud_security_group.public_sg.id

}

output "private_sg_id" {
  value = alicloud_security_group.private_sg.id

}

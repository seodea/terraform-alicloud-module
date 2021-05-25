
output "vpc_info" {

	value = module.dev_vpc
}

output "public_sg_info" {

	value = module.public_sg
}

output "was_sg_info" {

	value = module.was_sg
}

output "web_instances" {
	value = module.web_instances

}


output "was_instances" {
	value = module.was_instances

}

output "db_info" {

  value = module.mysql

}



output "vpc_info" {

	value = module.dev_vpc
}

output "test" {

	value = lookup(module.dev_vpc.public_info_map, "cn-shanghai-a")
}

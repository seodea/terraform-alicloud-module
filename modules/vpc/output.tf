# output.tf 
# 만약 모듈에서 output으로 얻기를 원하면 하위 모듈의 output에서 정의를 해야된다.

# VPC
output "vpc_id" {
  description = "VPC ID"
  value       = alicloud_vpc.this.id
}

output "vpc_cidr_block" {
  description = "VPC에 할당한 CIDR block"
  value       = alicloud_vpc.this.cidr_block
}

# subnets

#output "public_subnet_names" {
#  value       = join(",", alicloud_vswitch.private.*.name)
#
#}


# Region을 이용해서 vswitch id 선택을 위한 map 

output "public_info_map" {
  description = "Public Subnet ID 리스트"
  value       =  zipmap(alicloud_vswitch.public.*.availability_zone, alicloud_vswitch.public.*.id)
}

output "private_info_map" {
  description = "Public Subnet ID 리스트"
  value       =  zipmap(alicloud_vswitch.private.*.availability_zone, alicloud_vswitch.private.*.id)
}

output "db_info_map" {
  description = "Public Subnet ID 리스트"
  value       =  zipmap(alicloud_vswitch.database.*.availability_zone, alicloud_vswitch.database.*.id)
}

####

output "database_subnet_names" {
  value       = join(",", alicloud_vswitch.private.*.name)

}


# cidr
output "private_cidr"{
  value       = join(",", alicloud_vswitch.private.*.cidr_block)
}

output "public_cidr"{
  value       = join(",", alicloud_vswitch.public.*.cidr_block)

}

output "database_cidr"{
  value       = join(",", alicloud_vswitch.database.*.cidr_block)

}

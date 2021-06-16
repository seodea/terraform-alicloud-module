# 보안그룹 생성 코드

# Security Group

#resource "alicloud_security_group" "public_sg" {

#  name   = format("%s-pulic", var.sg_name) # variables 필요 - sg_name
#  vpc_id = var.vpc_id # module 내용
  
  #tags = merge(var.tags, map("Name", format("%s", var.sg_name))) # variables 필요 - tags
 
#}


##########################
# Ingress - Using a list of ports
##########################
#locals {
  // For compatibility: ingress_with_ports, priority_for_ingress_with_ports and protocol_for_ingress_with_ports
#  ingress_ports            = length(var.ingress_ports) > 0 ? var.ingress_ports : var.default_for_ingress_with_ports
#  default_ingress_priority = var.default_priority_for_ingress_with_ports > 0 ? var.default_priority_for_ingress_with_ports : var.default_ingress_priority

#  ingress_with_cidr_blocks_and_ports = flatten(
#    [
#      for _, obj in var.ingress_with_cidr_blocks_and_ports : [
#        for _, cidr in split(",", lookup(obj, "cidr_blocks", join(",", var.vpc_cidr))) : [
#          for _, port in split(",", lookup(obj, "ports", join(",", local.ingress_ports))) : {
#            cidr_block  = cidr
#            priority    = lookup(obj, "priority", var.default_ingress_priority)
#            from_port   = port
#            to_port     = port
#            protocol    = lookup(obj, "protocol", var.default_protocol_for_ingress_with_ports)
#            description = lookup(obj, "description", format("Ingress Rule With Cidr Block %s and Port %s", cidr, port))
#          }
#        ]
#      ]
#    ]
#  )
#}


locals {
	test = flatten(
		[
			for _, obj in var.ingress_with_cidr_blocks_and_ports : [
			  for _, cidr in split(",", lookup(obj,"cidr_blocks",join(",", ["10.0.0.0/16","192.168.0.0/24"]))) : {
			  cccc = cidr
			  }
			]


		]

	)
}

#resource "alicloud_security_group_rule" "ingress_with_cidr_blocks_and_ports" {
#  count             = length(local.ingress_with_cidr_blocks_and_ports) > 0 ? length(local.ingress_with_cidr_blocks_and_ports) : 0
#  security_group_id = alicloud_security_group.public_sg.id
#
#  type        = "ingress"
#  ip_protocol = lookup(local.ingress_with_cidr_blocks_and_ports[count.index], "protocol", )
#  nic_type    = "intranet"
#  port_range  = "${lookup(local.ingress_with_cidr_blocks_and_ports[count.index], "from_port", )}/${lookup(local.ingress_with_cidr_blocks_and_ports[count.index], "to_port", )}"
#  cidr_ip     = lookup(local.ingress_with_cidr_blocks_and_ports[count.index], "cidr_block", )
#  #priority    = lookup(local.ingress_with_cidr_blocks[count.index], "priority", )
#  description = lookup(local.ingress_with_cidr_blocks_and_ports[count.index], "description", )
#}
#

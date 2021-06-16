output "test" {
  #value = local.ingress_with_cidr_blocks_and_ports
  value = local.test
}

output "value_info" {

  value = var.ingress_with_cidr_blocks_and_ports
}

output "what" {

  value = length([lookup(var.ingress_with_cidr_blocks_and_ports[2], "cidr_blocks", join(",", var.vpc_cidr))])
}


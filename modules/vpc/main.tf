# main.tf

# VPC
resource "alicloud_vpc" "this" {
  cidr_block           = var.cidr
  name                 = var.name
  
  tags = merge(var.tags, map("Name", format("%s", var.name)))
}

# public subnet
resource "alicloud_vswitch" "public" {
  count = length(var.public_subnets)

  vpc_id            = alicloud_vpc.this.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.azs[count.index]
  name              = format("%s-public-VS-%s", var.name, var.azs[count.index])
  tags = merge(var.tags, map("Name", format("%s-public-%s", var.name, var.azs[count.index])))
}

# private subnet
resource "alicloud_vswitch" "private" {
  count = length(var.private_subnets)

  vpc_id            = alicloud_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]
  name              = format("%s-private-VS-%s", var.name, var.azs[count.index])
  tags = merge(var.tags, map("Name", format("%s-private-%s", var.name, var.azs[count.index])))
}

# private database subnet
resource "alicloud_vswitch" "database" {
  count = length(var.database_subnets)

  vpc_id            = alicloud_vpc.this.id
  cidr_block        = var.database_subnets[count.index]
  #cidr_block        = var.database_subnets[count.index] > 0 ? 1 : 0
  availability_zone = var.azs[count.index]
  name              = format("%s-database-VS-%s", var.name, var.azs[count.index])
  tags = merge(var.tags, map("Name", format("%s-db-%s", var.name, var.azs[count.index])))
}



# 보안그룹 생성 코드

# Security Group

resource "alicloud_security_group" "public_sg" {

  name   = format("%s-pulic", var.sg_name) # variables 필요 - sg_name
  vpc_id = var.vpc_id # module 내용

  tags = merge(var.tags, map("Name", format("%s", var.sg_name))) # variables 필요 - tags

}

resource "alicloud_security_group" "private_sg" {

  name   = format("%s-private", var.sg_name)
  vpc_id = var.vpc_id # module 내용

  tags = merge(var.tags, map("Name", format("%s", var.sg_name)))

}

# Public, Private Any Allow Port

resource "alicloud_security_group_rule" "public_sg_rule" {
  count = length(var.public_port)

  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = format("%s/%s", var.public_port[count.index],var.public_port[count.index]) # variables 필요 - public_port
  priority          = 1
  security_group_id = alicloud_security_group.public_sg.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "private_sg_rule" {
  count = length(var.private_port)

  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = format("%s/%s", var.private_port[count.index],var.private_port[count.index])
  priority          = 1
  security_group_id = alicloud_security_group.private_sg.id

  # 80,443이면 0.0.0.0/0으로 아니고 22면 121.x.x.x 으로
  cidr_ip           = var.private_port[count.index] == "80" || var.private_port[count.index] == "443" ? "0.0.0.0/0" : var.vpc_cidr
}

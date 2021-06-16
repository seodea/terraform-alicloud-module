# SG info

variable "sg_name" {
  description = "모듈에서 정의하는 모든 리소스 이름의 prefix"
  type        = string
  default = "tf-temp-sg"
}

variable "public_port" {
  description = "보안그룹 Public Open Port"
  type        = list
  default = ["80", "443","22"]
}

variable "vpc_cidr"{
  type        = string
}

variable "private_port" {
  description = "보안그룹 Public Open Port"
  type        = list
  default = ["22"]
}

variable "vpc_id" {
  type        = string	
}

variable "tags" {
  description = "모든 리소스에 추가되는 tag 맵"
  type        = map
  default = {
    "TerraformManaged" = "true"
  }
}



# 테스트 ECS variables 파일

# variables.tf

# 공통
variable "azs" {
  description = "사용할 availability zones 리스트"
  type        = string
  default = ""
}

# ECS 필수 변수
variable "ecs_password" {
  default = "Test12345"
}

##### ecs info

variable "ecs_name" {
  type = string
}

#       #
# count #
#       #

variable "ecs_count" {
  type = string
  default = "2"
}

#       #
# image #
#       #
# public, private 동일한 이미지 사용

variable "ecs_image" {
    type = string
    default = "^centos_7"
}

#        #
#  type  #
#        #

variable "ecs_type" {
  type = string
  default = "ecs.n1.medium"
}

#       #
#  EIP  #
#       #

variable "eip_count" {
    type = string
    default = "0"
}

#        #
#  size  #
#        #

variable "disk_size" {
  type = string
  default = "40"
}

#        #
#   SG   #
#        #


variable "ecs_sg_id" {
  type = string
}


variable "ecs_vswitch_id" {
  type = string
}


###### 공통

variable "role" {
  default = "example-ecs-vpc"
}

variable "ssh_username" {
  default = "root"
}

variable "number_format" {
  default = "%02d"
}

variable "instance_charge_type" {
  default = "PostPaid"
}

variable "system_disk_category" {
  default = "cloud_efficiency"
}

variable "internet_charge_type" {
  default = "PayByTraffic"
}

variable "internet_max_bandwidth_out" {
  default = 200
}

variable "internet_max_bandwidth_in" {
  default = 200
}


#data "alicloud_zones" "default" {
#  available_disk_category = var.disk_category
#  available_instance_type = data.alicloud_instance_types.default.instance_types[0].id
#}

#data "alicloud_instance_types" "default" {
#  instance_type_family = "ecs.n1"
#  availability_zone = var.azs[0]
#  cpu_core_count       = 1
#  memory_size          = 2
#}

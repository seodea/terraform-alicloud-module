# SG info

variable "sg_name" {
  description = "모듈에서 정의하는 모든 리소스 이름의 prefix"
  type        = string
  default = "tf-temp-sg"
}

variable "vpc_id" {
  type        = string	
  default     = "id-vpc"

}

variable "tags" {
  description = "모든 리소스에 추가되는 tag 맵"
  type        = map
  default = {
    "TerraformManaged" = "true"
  }
}

##############################
####### default value ########
##############################

variable "default_ingress_priority" {
  description = "A default ingress priority."
  type        = number
  default     = 50
}

variable "vpc_cidr" {
  description = "The IPv4 CIDR ranges list to use on ingress cidrs rules."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "default_for_ingress_with_ports" {
  type        = list(number)
  default     = ["22","3389"]
}
variable "default_protocol_for_ingress_with_ports" {
  type        = string
  default     = "tcp"
}
variable "default_priority_for_ingress_with_ports" {
  type        = number
  default     = 1
}

###########################
####### Test value ########
###########################

variable "ingress_with_cidr_blocks_and_ports" {
  description = "List of ingress rules to create where `cidr_blocks` and `ports` is used. The valid keys contains `cidr_blocks`, `ports`, `protocol`, `description` and `priority`. The ports item's `from` and `to` have the same port. Example: '80,443' means 80/80 and 443/443."
  type        = list(map(string))
  default     = [
    {
      ports       = "10,20,30"
      protocol    = "tcp"
      priority    = 1
      cidr_blocks = "10.10.0.0/20,10.11.0.0/20"
    },
    {
      # Using ingress_ports to set ports
      protocol    = "udp"
      description = "ingress for tcp"
      cidr_blocks = "172.10.0.0/20"
    },
    {
      # Using ingress_ports and ingress_cidr_blocks to set ports and cidr_blocks
      protocol    = "icmp"
      priority    = 20
      description = "ingress for icmp"
    }
  ]
}

variable "ingress_ports" {
  description = "sg rule에 포트 정의가 없을 경우, 해당 port를 기준으로 정책 설정"
  type        = list(number)
  default     = []
}

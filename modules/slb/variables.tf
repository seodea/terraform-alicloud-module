
# VSwitch variables
variable "vswitch_id" { 
  description = "The vswitch id used to launch load balancer."
  type        = string
  default     = ""
}

# Load Balancer Instance variables

variable "name" {
  description = "The name of a new load balancer."
  type        = string
  default     = "tf-module-slb"
}

variable "address_type" {
  description = "The type of address. Choices are 'intranet' and 'internet'. Default to 'internet'."
  type        = string
  default     = "internet"
}

variable "internet_charge_type" {
  description = "The charge type of load balancer instance internet network."
  type        = string
  default     = "PayByTraffic"
}

variable "specification" {
  description = "The specification of the SLB instance."
  type        = string
  default     = "slb.s1.small"
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "master_zone_id" {
  description = "The primary zone ID of the SLB instance. If not specified, the system will be randomly assigned."
  type        = string
  default     = ""
}

variable "slave_zone_id" {
  description = "The standby zone ID of the SLB instance. If not specified, the system will be randomly assigned."
  type        = string
  default     = ""
}

# Load Balancer Instance attachment

variable "virtual_server_group_name" {
  description = "The name virtual server group. If not set, the 'name' and adding suffix '-virtual' will return."
  type        = string
  default     = ""
}

variable "servers_of_virtual_server_group" {
  description = "A list of servers attaching to virtual server group, it's supports fields 'server_ids', 'weight'(default to 100), 'port' and 'type'(default to 'ecs')."
  type        = list(map(string))
  default     = []
}



#################
### Listener
#################

# Load Balancer Instance variables

# Listener common variables
variable "listeners" {
  description = "List of slb listeners. Each item can set all or part fields of alicloud_slb_listener resource."
  type        = list(map(string))
  default     = []
}

# bandwidth
variable "bandwidth" {
  description = "The type of address. Choices are 'intranet' and 'internet'. Default to 'internet'."
  type        = map(string)
  default     = {}
}

variable "health_check" {
  description = "The slb listener health check settings to use on listeners. It's supports fields 'healthy_threshold','unhealthy_threshold','health_check_timeout', 'health_check', 'health_check_type', 'health_check_connect_port', 'health_check_domain', 'health_check_uri', 'health_check_http_code', 'health_check_method' and 'health_check_interval'"
  type        = map(string)
  default     = {}
}

variable "advanced_setting" {
  description = "The slb listener advanced settings to use on listeners. It's supports fields 'sticky_session', 'sticky_session_type', 'cookie', 'cookie_timeout', 'gzip', 'persistence_timeout', 'acl_status', 'acl_type', 'acl_id', 'idle_timeout' and 'request_timeout'."
  type        = map(string)
  default     = {}
}

variable "x_forwarded_for" {
  description = "Additional HTTP Header field 'X-Forwarded-For' to use on listeners. It's supports fields 'retrive_slb_ip', 'retrive_slb_id' and 'retrive_slb_proto'"
  type        = map(bool)
  default     = {}
}

variable "ssl_certificates" {
  description = "SLB Server certificate settings to use on listeners. It's supports fields 'tls_cipher_policy', 'server_certificate_id' and 'enable_http2'"
  type        = map(string)
  default     = {}
}



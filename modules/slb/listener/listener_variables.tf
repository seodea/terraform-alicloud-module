variable "region" {
  description = "The region used to launch this module resources."
  type        = string
  default     = ""
}

# Load Balancer Instance variables
variable "slb" {
  description = "The load balancer ID used to add one or more listeners."
  type        = string
}

# Listener common variables
variable "listeners" {
  description = "List of slb listeners. Each item can set all or part fields of alicloud_slb_listener resource."
  type        = list(map(string))
  default     = []
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


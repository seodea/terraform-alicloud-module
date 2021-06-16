# RDS main.tf
# 삭제 가능

#data "alicloud_db_instance_classes" "default" {
#  engine         = var.engine
#  engine_version = var.engine_version
#  category       = "HighAvailability"
#  storage_type   = var.instance_storage_type
#}

################
# RDS Instance
################


resource "alicloud_db_instance" "rds_instance" {
  engine               = var.engine
  engine_version       = var.engine_version
  instance_type        = var.instance_type
  instance_storage     = var.instance_storage
  instance_charge_type = var.instance_charge_type
  instance_name        = var.instance_name
  security_ips         = var.security_ips
  vswitch_id           = var.vswitch_id
  zone_id              = var.master_zone
  zone_id_slave_a      = var.slave_zone
  tags                 = var.tags
  security_group_ids   = var.security_group_ids
}

################
# RDS Backup policy
################

resource "alicloud_db_backup_policy" "this" {
  instance_id       = alicloud_db_instance.rds_instance.id
  preferred_backup_period     = var.preferred_backup_period
  preferred_backup_time       = var.preferred_backup_time
  backup_retention_period     = var.backup_retention_period
  log_backup_retention_period = var.log_backup_retention_period
  enable_backup_log           = var.enable_backup_log
}

################
# RDS Public Endpoint Connection
################
// 원하지 않을 경우 주석처리

#resource "alicloud_db_connection" "db_connection" {
#  instance_id       = alicloud_db_instance.rds_instance.id
#  connection_prefix = var.connection_prefix
#  port              = var.port
#}

################
# RDS Database
################

resource "alicloud_db_database" "this" {
  count         = var.create_database ? length(var.databases) : 0
  instance_id   = alicloud_db_instance.rds_instance.id
  name          = lookup(var.databases[count.index], "name")
  character_set = lookup(var.databases[count.index], "character_set")
  description   = lookup(var.databases[count.index], "description")
}

################
# RDS Database account
################

resource "alicloud_db_account" "this" {
  count       = var.create_account && var.account_name != "" ? 1 : 0
  instance_id   = alicloud_db_instance.rds_instance.id
  name        = var.account_name
  password    = var.password
  type        = var.type
}

resource "alicloud_db_account_privilege" "this" {
  count        = var.create_account && var.create_database && length(var.databases) > 0 ? 1 : 0
  instance_id   = alicloud_db_instance.rds_instance.id
  account_name = concat(alicloud_db_account.this.*.name, [""])[0]
  db_names     = alicloud_db_database.this.*.name
  privilege    = var.privilege
}

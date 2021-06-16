
module "mysql" {
  source = "./module"
  region = "cn-shanghai"
  
  #################
  # Rds Instance
  #################
  engine               = "MySQL"
  engine_version       = "8.0"
  instance_type        = "rds.mysql.s2.large"
  instance_storage     = 20
  instance_charge_type = "Postpaid"
  instance_name        = "dev-rds"
  security_group_ids   = [] # 필수인지?
  vswitch_id           = "vsw-uf664nwetcqg8idogp9tu"
  security_ips         = ["1.1.1.0/24","2.2.2.0/24"]
  master_zone          = "cn-shanghai-a"
  slave_zone           = "auto"
  tags                 = { 
  
    created = "Terraform"

  }
 
  #################
  # Rds Backup policy
  #################
  preferred_backup_period     = ["Monday", "Wednesday"]
  # UTC 영향으로 설정 시간에서 +9:00이 적용받습니다. 
  // 00:00Z-01:00Z 01:00Z-02:00Z 02:00Z-03:00Z 03:00Z-04:00Z 04:00Z-05:00Z 05:00Z-06:00Z 06:00Z-07:00Z 07:00Z-08:00Z 08:00Z-09:00Z 09:00Z-10:00Z 10:00Z-11:00Z 11:00Z-12:00Z 12:00Z-13:00Z 13:00Z-14:00Z 14:00Z-15:00Z 15:00Z-16:00Z 16:00Z-17:00Z 17:00Z-18:00Z 18:00Z-19:00Z 19:00Z-20:00Z 20:00Z-21:00Z 21:00Z-22:00Z 22:00Z-23:00Z 23:00Z-24:00Z

  preferred_backup_time       = "15:00Z-16:00Z" # 한국시간 00:00-01:00 작업
  backup_retention_period     = 7
  log_backup_retention_period = 7
  #enable_backup_log           = ture
  
  #################
  # Rds public endpoint  Connection
  #################
  #allocate_public_connection = false
  #port                       = 13306 # default 3306
  #connection_prefix          = "dev-rds-demo"
  
  #################
  # Rds Database account
  #################
  type           = "Normal"
  privilege      = "ReadWrite" #default ReadOnly
  account_name   = "megazone"
  password       = "test123!@#"
  
  #################
  # Rds Database
  #################
  databases       = [
    {
      name = "dbuserv1"
      character_set = "utf8"
      description   = "db1"
    },
    {
      name = "dbuserv2"
      character_set = "utf8"
      description   = "db2"
    }
  ]
}


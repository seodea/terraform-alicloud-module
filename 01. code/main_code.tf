locals {
  region = "Your Region"
  azs    = ["Your Zone A", "Your Zone B"]
  public_subnets   = ["Your public subnet A","Your public subnet B"]
  private_subnets  = ["Your Private subnet A","Your Private subnet B"]
  database_subnets = ["Your DB subnet A","Your DB subnet B"]
}

# 3tire 생성 모듈

module "dev_vpc" {
  # source는 variables.tf, main.tf, outputs.tf 파일이 위치한 디렉터리 경로를 넣어준다.
  source = "../modules/vpc"

  # VPC이름을 넣어준다. 이 값은 VPC module이 생성하는 모든 리소스 이름의 prefix가 된다
  name = "Your VPC Name"

  # VPC의 CIDR block을 정의한다. subnet과 동일하 대역대 선택
  cidr = "Your VPC CIDR"

  # VPC가 사용할 AZ를 정의한다.
  azs               = local.azs
  # VPC의 Public Subnet CIDR block을 정의한다. (Public 말고 다른 이름으로도 가능.)
  public_subnets    = local.public_subnets

  # VPC의 Private Subnet CIDR block을 정의한다.
  private_subnets   = local.private_subnets

  # VPC의 Private DB Subnet CIDR block을 정의한다. (RDS를 사용하지 않으면 이 라인은 필요없다.)
  database_subnets  = local.database_subnets

# VPC module이 생성하는 모든 리소스에 기본으로 입력될 Tag를 정의한다.
  tags = {
    "TerraformManaged" = "true"
  }
}

module "public_sg" {

  source = "../modules/sg"
  
  // 끝에 -sg 가 자동으로 붙습니다.
  sg_name = "Your Public SG Name" 

  vpc_id = module.dev_vpc.vpc_id 
  vpc_cidr = [module.dev_vpc.vpc_cidr_block]


  ingress_ports = [80,443] # Port 정의가 없을 경우, [22,3389]를 기본으로 할당
  
  # 3개의 항목 중 사용하고자 하는 방식 이외는 꼭 삭제를 해야합니다.
  ingress_with_cidr_blocks_and_ports = [
    {
      # 모든 내용 (port, protocol, priority,cidr)이 있을경우, 해당 내용으로 할당
      ports       = "21,22"
      protocol    = "tcp"
      priority    = 1
      cidr_blocks = "Your IP/32"
    },
    {
      # port의 정의가 없을 경우, ingress_ports에서 정의한 port를 기준으로 할당
      # protocole 정의가 없을 경우, 기본값인 TCP로 할당
      protocol    = "tcp"
      description = "ingress for tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      # cidr이 정의가 없을 경우 vpc_cidr에서 정의한 cidr을 기준으로 할당
      protocol    = "icmp"
      priority    = 2
      description = "ingress for icmp"
    }
  ]
}

module "was_sg" {

  source = "../modules/sg"

  // 끝에 -sg 가 자동으로 붙습니다.
  sg_name = "dev-was"

  vpc_id = module.dev_vpc.vpc_id
  vpc_cidr = [module.dev_vpc.vpc_cidr_block]


  ingress_ports = [80] # Port 정의가 없을 경우, [22,3389]를 기본으로 할당

  # 3개의 항목 중 사용하고자 하는 방식 이외는 꼭 삭제를 해야합니다.
  ingress_with_cidr_blocks_and_ports = [
    {
      # 모든 내용 (port, protocol, priority,cidr)이 있을경우, 해당 내용으로 할당
      ports       = "21,22"
      protocol    = "tcp"
      priority    = 1
      cidr_blocks = module.dev_vpc.public_cidr
    },
    {
      # port의 정의가 없을 경우, ingress_ports에서 정의한 port를 기준으로 할당
      # protocole 정의가 없을 경우, 기본값인 TCP로 할당
      protocol    = "tcp"
      description = "ingress for tcp"
      cidr_blocks = module.dev_vpc.public_cidr #vpc 생성할때 public cidr을 원할 경우 모듈로 작업 가능
    },
    {
      # cidr이 정의가 없을 경우 vpc_cidr에서 정의한 cidr을 기준으로 할당
      protocol    = "icmp"
      priority    = 2
      description = "ingress for icmp"
    }
  ]
}

module "web_instances" {

  source = "../modules/ecs"

 # 기본 type 선택용 Region 선택
  azs  = local.azs[0]
 # ECS Count 선택
  ecs_count = "2"

 # ECS Name 입력
  ecs_name = "Your Web Name"
 
 # PW 입력
  ecs_password = "Test123!@#"

 # ECS Image 선택 (^centos_7의 경우 Centos 7 버전중 최슨으로 전달) 
  ecs_image = "^centos_7"

 # ECS type
  ecs_type = "ecs.n1.medium"

 # EIP 수량 선택 (필요하지 않을 경우 0 이나 "" 입력)
  eip_count = "2"

 # System disk size 선택 (기본값 window - 40GB, linux - 20GB)
  disk_size = "40"

 # vswitch 정보 (vpc 생성 시 map에서 등록한 리전 순으로 0,1)
  ecs_vswitch_id = lookup(module.dev_vpc.public_info_map, local.azs[0])
 # SG 정보
  ecs_sg_id = module.public_sg.sg_id
}

module "was_instances" {

  source = "../modules/ecs"

 # 기본 type 선택용 Region 선택
  azs  = local.azs[0]

 # ECS Count 선택
  ecs_count = "2"

 # ECS Name 입력- name-01, name-02 순으로 네이밍이 됩니다.
  ecs_name = "Your WAS Name"

 # PW 입력
  ecs_password = "Test123!@#"

 # ECS Image 선택 (^centos_7의 경우 Centos 7 버전중 최슨으로 전달)
  ecs_image = "^centos_7"

 # ECS type
  ecs_type = "ecs.n4.large"

 # System disk size 선택 (기본값 window - 40GB, linux - 20GB)
  disk_size = "40"

 # vswitch 정보 (vpc 생성 시 map에서 등록한 리전 순으로 0,1)
  ecs_vswitch_id = lookup(module.dev_vpc.private_info_map, "cn-shanghai-a")
 
 # SG 정보
  ecs_sg_id = module.was_sg.sg_id
}

module "mysql" {
  source = "../modules/rds/"
  region = local.region
  
  #################
  # Rds Instance
  #################
  engine               = "MySQL"
  engine_version       = "8.0"
  instance_type        = "rds.mysql.s2.large"
  instance_storage     = 20
  instance_charge_type = "Postpaid"
  instance_name        = "dev-rds"
  security_group_ids   = [] 
  vswitch_id           = lookup(module.dev_vpc.public_info_map, local.azs[0])
  security_ips         = local.private_subnets
  master_zone          = local.azs[0]
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


module "dev_public_slb" {
  
  source  = "../modules/slb"
  
  #####
  #  SLB instance
  #####
  name = "Your public slb Name"
  internet_charge_type = "PayByTraffic" # 기본값 PaybyTraffic
  address_type         = "internet" # [internet, intranet] 중 선택
  vswitch_id           = lookup(module.dev_vpc.public_info_map, "cn-shanghai-a") # internet일 경우 무시 
  specification        = "slb.s1.small" # 기본값:"slb.s1.small" 나머지 선택 "slb.s2.small", "slb.s2.medium", "slb.s3.small", "slb.s3.medium", "slb.s3.large" and "slb.s4.large"  
  master_zone_id       = local.azs[0]
  slave_zone_id        = local.azs[1]
  
  ########################
  #attach virtual servers#
  ########################
  servers_of_virtual_server_group = [
    {
      # 여러대 넣을 경우, "i-asd,i-asd"
      server_ids = lookup(module.web_instances, "ecs_ids")
      port       = "80"
      type       = "ecs" # 기본값 ecs, 안적어도 무관
      weight     = 100 # 기본값 100, 안적어도 무관
    }
  ]


  ##########
  # Liteners 원하는걸 일일이 기입이 필수
  ##########
  
  listeners = [
    {
      backend_port      = "80"
      frontend_port     = "80"
      
      # protocol을 원하는 걸로 변경 L4 - TCP UDP, L7 - HTTP HTTPS
      protocol          = "http"
      bandwidth         = "-1"
      scheduler         = "wrr"
      healthy_threshold = "4"
      gzip              = "false"
      health_check_type = "tcp"
    }
  ]
  
  // health_check will apply to all of listeners if health checking is not set in the listeners
  health_check = {
    health_check              = "on"
    health_check_type         = "tcp"
    healthy_threshold         = "3"
    unhealthy_threshold       = "2"
    health_check_timeout      = "5"
    health_check_interval     = "2"
    health_check_connect_port = "80"
    health_check_uri          = "/"
    health_check_http_code    = "http_2xx"
  }
  
  // advanced_setting will apply to all of listeners if some fields are not set in the listeners
  advanced_setting = {
    
    gzip                = "false"
    persistence_timeout = "5"
  }
  
  // x_forwarded_for will apply to all of listeners if it is not set in the listeners
  x_forwarded_for = {
    retrive_slb_ip    = "true"
    retrive_slb_id    = "false"
    retrive_slb_proto = "true"
  }
  
  ssl_certificates = {
  }
}

module "dev_internal_slb" {
  
  source  = "../modules/slb"
  
  #####
  #  SLB instance
  #####
  name = "Your Internal SLB Name"
  internet_charge_type = "PayByTraffic" # 기본값 PaybyTraffic
  address_type         = "intranet" # [internet, intranet] 중 선택
  vswitch_id           = lookup(module.dev_vpc.public_info_map, "cn-shanghai-a") # internet일 경우 무시 
  specification        = "slb.s1.small" # 기본값:"slb.s1.small" 나머지 선택 "slb.s2.small", "slb.s2.medium", "slb.s3.small", "slb.s3.medium", "slb.s3.large" and "slb.s4.large"  
  master_zone_id       = local.azs[0]
  slave_zone_id        = local.azs[1]
  
  ########################
  #attach virtual servers#
  ########################
  servers_of_virtual_server_group = [
    {
      # 여러대 넣을 경우, "i-asd,i-asd"
      server_ids = lookup(module.was_instances, "ecs_ids")
      port       = "1234"
      type       = "ecs" # 기본값 ecs, 안적어도 무관
      weight     = 100 # 기본값 100, 안적어도 무관
    }
  ]


  ##########
  # Liteners 원하는걸 일일이 기입이 필수
  ##########
  
  listeners = [
    {
      backend_port      = "1234"
      frontend_port     = "1234"
      
      # protocol을 원하는 걸로 변경 L4 - TCP UDP, L7 - HTTP HTTPS
      protocol          = "tcp"
      scheduler         = "wrr"
      healthy_threshold = "4"
      gzip              = "false"
      health_check_type = "tcp"
    }
  ]
  
  // health_check will apply to all of listeners if health checking is not set in the listeners
  health_check = {
    health_check              = "on"
    health_check_type         = "tcp"
    healthy_threshold         = "3"
    unhealthy_threshold       = "2"
    health_check_timeout      = "5"
    health_check_interval     = "2"
    health_check_connect_port = "80"
    health_check_uri          = "/"
    health_check_http_code    = "http_2xx"
  }
  
  // advanced_setting will apply to all of listeners if some fields are not set in the listeners
  advanced_setting = {
    
    gzip                = "false"
    persistence_timeout = "5"
  }
  
  // x_forwarded_for will apply to all of listeners if it is not set in the listeners
  x_forwarded_for = {
    retrive_slb_ip    = "true"
    retrive_slb_id    = "false"
    retrive_slb_proto = "true"
  }
  
  ssl_certificates = {
  }
}

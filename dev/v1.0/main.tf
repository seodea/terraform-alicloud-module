# 3tire 생성 모듈

module "dev_vpc" {
  # source는 variables.tf, main.tf, outputs.tf 파일이 위치한 디렉터리 경로를 넣어준다.
  source = "../modules/vpc"

  # VPC이름을 넣어준다. 이 값은 VPC module이 생성하는 모든 리소스 이름의 prefix가 된다
  name = "tf-dev"

  # VPC의 CIDR block을 정의한다.
  cidr = "172.16.0.0/16"

  # VPC가 사용할 AZ를 정의한다.
  azs              = ["cn-shanghai-a", "cn-shanghai-b"]

  # VPC의 Public Subnet CIDR block을 정의한다. (Public 말고 다른 이름으로도 가능.)
  public_subnets   = ["172.16.0.0/24","172.16.100.0/24"]

  # VPC의 Private Subnet CIDR block을 정의한다.
  private_subnets  = ["172.16.1.0/24","172.16.101.0/24"]

  # VPC의 Private DB Subnet CIDR block을 정의한다. (RDS를 사용하지 않으면 이 라인은 필요없다.)
  database_subnets = ["172.16.2.0/24","172.16.102.0/24"]

# VPC module이 생성하는 모든 리소스에 기본으로 입력될 Tag를 정의한다.
  tags = {
    "TerraformManaged" = "true"
  }
}

module "public_sg" {

  source = "../modules/sg"

  sg_name = "dev-sg"

  vpc_id = module.dev_vpc.vpc_id 
  vpc_cidr = [module.dev_vpc.vpc_cidr_block]


  ingress_ports = [22,3389] # Port 정의가 없을 경우, [22,3389]를 기본으로 할당

  ingress_with_cidr_blocks_and_ports = [
    {
      # 모든 내용 (port, protocol, priority,cidr)이 있을경우, 해당 내용으로 할당
      ports       = "21,22"
      protocol    = "tcp"
      priority    = 1
      cidr_blocks = "172.16.0.0/24,172.16.100.0/24"
    },
    {
      # port의 정의가 없을 경우, ingress_ports에서 정의한 port를 기준으로 할당
      # protocole 정의가 없을 경우, 기본값인 TCP로 할당
      protocol    = "udp"
      description = "ingress for tcp"
      cidr_blocks = "172.16.1.0/24,172.16.101.0/24"
    },
    {
      # cidr이 정의가 없을 경우 ingress_cidr_blocks에서 정의한 cidr을 기준으로 할당
      protocol    = "icmp"
      priority    = 2
      description = "ingress for icmp"
    }
  ]
}

module "web_instances" {

  source = "../modules/ecs"

 # 기본 type 선택용 Region 선택
  azs = "cn-shanghai-a"

 # ECS Count 선택
  ecs_count = "2"

 # ECS Name 입력
  ecs_name = "web"
 
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
  #ecs_vswitch_id = module.dev_vpc.public_subnet_ids[0]
  ecs_vswitch_id = lookup(module.dev_vpc.public_info_map, "cn-shanghai-a")
 # SG 정보
  ecs_sg_id = module.public_sg.public_sg_id

}

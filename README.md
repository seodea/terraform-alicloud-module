# Terraform module을 이용한 Resources 관리

# Terraform 알고 사용하자

## Overview

Terraform Code를 Module화 하여 모든 사용자가 전체 코드를 모르더라도, 변수값 변경을 통해 원하는 인스턴스를 생성하고 테라폼으로 관리가 가능합니다. 향후에 Module화에 추가로 다양한 서비스 생성 코드를  추가로 생성이 가능하게 하는데 기반이 될수있게 합니다.

## 목표

HOL을 통해서 Module의 코드를 이해하고 수정하여 원하는 아키텍쳐를 배포를 할 수 있습니다.

## 사전 구성

Terraform을 설치가 되어 있어야 합니다

Terraform 설치는 [**여기**](https://www.44bits.io/ko/post/terraform_introduction_infrastrucute_as_code)를 따라서 설치해 주세요

## STEP 0. 사용하는 구문

VPC, vSwitch, ECS, Security Group, RDS, SLB에 대한 Terraform Code를 사용을 합니다.

Terraform에서 제공하는 Alibaba Cloud Provider는 첨부한 링크를 통해서 더 자세하게 보실 수 있습니다

[https://registry.terraform.io/providers/aliyun/alicloud/latest/docs](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs)

추가로 Terraform HCL 언어에서 제공하는 다양한 함수를 사용을 합니다. 

for, count, Local, lookup 등을 사용하여 검색 및 변수 전달 용도를 위해서 사용을 합니다.

## STEP 1. Module 이란?

Terraform의 경우 폴더 단위가 하나의 Module로 인식을 하고 관리를 합니다. 각 서비스 별로 하나의 폴더로 생성을 하고 Code 저장을 할 수는 있으나, 추후에 트러블슈팅 및 관리에 어려움이 있습니다. 

현재 테스트 환경에서는 아래와 같이 폴더를 나누어 놨습니다. 

```
- 01.code : 메인 폴더
  ㄴ main_code.tf : main terraform 파일
  ㄴ config.tf : terraform 접속 계정 정보 파일(실사용에선 환경변수 추천)
  ㄴ output.tf : terraform output 파일

- 02.test_code : 테스트용 폴더
  ㄴ main_code.tf : 생성 테스트용 모든 변수 기입된 tf 파일 (테스트용)
  ㄴ config.tf : terraform 접속 계정 정보 파일(실사용에선 환경변수 추천)
  ㄴ output.tf : terraform output 파일

- modules : terraform code 저장 폴더
  ㄴ ecs : ecs 생성 code 저장 폴더
  ㄴ rds : rds 생성 code 저장 폴더
  ㄴ sg : sg 생성 code 저장 폴더
  ㄴ slb : slb 생성 code 저장 폴더
  ㄴ vpc : vpc 생성 code 저장 폴더
```

dev 폴더는 원하는 서비스를 생성하기 위한 변수를 저장하고 있습니다. modules 폴더는 module에서 사용하는 각 서비스 생성 코드를 저장하고 있습니다.

### STEP 1.0 Local 변수 등록

Terraform code에서 제공하는 Local 변수를 이용하면 여러번 사용하는 변수를 한번만 정의를 하여 사용을 할 수있습니다. 지금과 같이 모듈화를 한 code에서는 더 유용하게 쓰입니다.

인스턴스를 생성을 할 때, 가장 많이 사용을 하게되는 region, zone, subnet에 대한 정보를 locals로 처리했습니다.

```
locals {
  region = "Your Region"
  azs    = ["Your Zone A", "Your Zone B"]
  public_subnets   = ["Your public subnet A","Your public subnet B"]
  private_subnets  = ["Your Private subnet A","Your Private subnet B"]
  database_subnets = ["Your DB subnet A","Your DB subnet B"]
}
```

### STEP 1.1 VPC 생성

인프라의 기본이 되는 VPC 생성을 하는 구문입니다. 

- 모듈 변수 Code
    - vpc 생성 파일을 위한 Module 코드입니다.

    ```
    module "dev_vpc" {
      # source는 variables.tf, main.tf, outputs.tf 파일이 위치한 디렉터리 경로를 넣어준다.
      source = "../modules/vpc"

      # VPC이름을 넣어준다. 이 값은 VPC module이 생성하는 모든 리소스 이름의 prefix가 된다
      name = "Your VPC Name"

      # VPC의 CIDR block을 정의한다. 위에 정의한 subnet를 포함하는 대역대를 기입합니다.
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
    ```

    - source : 코드가 저장되어있는 폴더의 경로를 지정
    - name : vpc, vswitch의 이름을 기입
    - cidr : 원하는 vpc의 cidr 기입
    - azs : 원하는 zone을 ["",""] 형태로 기입 (locals 변수를 사용)
    - public_subnets : 원하는 public subnet을 ["",""] 형태로 기입 (locals 변수를 사용)
    - private_subnets : 원하는 private subnet을 ["",""] 형태로 기입 (locals 변수를 사용)
    - database_subnets : 원하는 database subnet을 ["",""] 형태로 기입 (locals 변수를 사용)
    - tags : tag를 이용해서 관리할 경우 기입 "key" = "value" 형태로 기입

- 인스턴스 생성 모듈화 코드

VPC 생성 code 참고 : [modules/vpc 폴더 참고](https://github.com/seodea/terraform-alicloud-module/tree/main/modules/vpc)

### STEP 1.2 보안그룹 생성

ECS을 생성 전에 ECS가 사용해야되는 보안그룹을 생성을 합니다. 해당 가이드에서는 public용, was용으로 2개를 동일한 zone A에 생성할 예정입니다.

1) dev-public-sg 보안정책 내용

- 80,443 port : 0.0.0.0/0
- 21, 22 port : "Your Public IP"
- ICMP : 172.16.0.0/16 (VPC Network)

2) dev-was-sg 보안정책 내용

- 80 port : 172.16.0.0/24, 172.16.100.0/24 (public subnet)
- 21, 22 port : 172.16.0.0/24, 172.16.100.0/24 (public subnet)
- ICMP : 172.16.0.0/16 (VPC Network)

- 모듈 변수 Code
    - 보안그룹 생성에 필요한 변수 값들을 기입합니다.

        1) 보안그룹 정책에 필요한 내용이 모두 있을 경우 : 첫번째 코드

        2) 보안그룹 정책에 port를 지정하지 않을 경우 : 두번째 코드

        ingress_ports 변수에 정의한 port가 적용됩니다.

        3) 보안그룹 정책에 cidr을 지정하지 않을 경우 : 세번째 코드

        vpc_cidr 변수에 정의한 cidr이 적용됩니다.

    ```
    module "public_sg" {

      source = "../modules/sg"

      // 끝에 -sg 가 자동으로 붙습니다.
      sg_name = "Your public SG Name" 

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
      sg_name = "Your WAS SG Name"

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
    ```

    - sg_name : 보안그룹의 이름 기입
    - vpc_id : vpc 생성 시 생기는 id를 자동으로 가져옴 (vpc 모듈에서 미리 output으로 정보를 받아옴)
    - vpc_cidr : vpc 생성 후 cidr 정보를 자동으로 가져옴  (vpc 모듈에서 미리 output으로 정보를 받아옴)
    - ingress_ports : 원하는 port 번호를 [21,22] 처럼 기입
    아래 변수값에서 port의 정의가 없을 경우, 해당 변수를 사용하여 정책 설정
    - ingress_with_cidr_blocks_and_ports : 보안그룹에 적용할 내용을 기입
        - ports : 원하는 port를 기입. 단, 2개 이상일 경우 "21","22" 형태로 기입 (필수 o)
        단, 미기입시 ingress_ports에 기입한 port로 대체
        - protocol : TCP, UDP를 선택 후 기입. 단, 미 기입시 기본값인 TCP로 설정 (필수 x)
        - priority : 우선순위를 기입. 기본값 "1" (필수 x)
        - cidr_blocks : 허용을 하고자 하는 cidr 기입. 2개 이상일 경우 "1.1.1.1","2.2.2.2" 형태로 기입 (필수 o)
        단, 미기입시 vpc_cidr 값으로 대체. 외부 public IP 경우 필수로 기입
        - description : 설명을 기입

보안그룹 생성 code 참고 : [modules/sg 폴더 참고](https://github.com/seodea/terraform-alicloud-module/tree/main/modules/sg)

### STEP 1.3 ECS 인스턴스 생성

ECS 인스턴스를 생성을 합니다. 해당 가이드에서는 web용 ECS 2EA, was용 ECS 2EA를 생성을 합니다. web용의 경우 EIP를 연결을 합니다. 

- Public : 2 EA (공인망) + EIP
- WAS : 2 EA (사설망)

- 모듈 변수 Code
    - ecs Module에 ecs 용도에 맞게 기입 및 변수를 입력을 합니다. ECS 생성코드를 이용해서 생성을 하므로 용도 별로 각각 아래와 같이 사용을 해야합니다.

    ```
    module "web_instances" {

    source = "../modules/ecs"

     # 기본 type 선택용 Region 선택
      azs  = local.azs[0]
     # ECS Count 선택
      ecs_count = "2"

     # ECS Name 입력 - name-01, name-02 순으로 네이밍이 됩니다.
      ecs_name = "Your Web Server Name"

     # PW 입력
      ecs_password = "Your Password"

     # ECS Image 선택 (^centos_7의 경우 Centos 7 버전중 최슨으로 전달) 
      ecs_image = "Your OS Image"

     # ECS type
      ecs_type = "Your ECS Type"

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

     # ECS Name 입력 - name-01, name-02 순으로 네이밍이 됩니다.
      ecs_name = "Your Was Server Name"

     # PW 입력
      ecs_password = "Your Password"

     # ECS Image 선택 (^centos_7의 경우 Centos 7 버전중 최슨으로 전달)
      ecs_image = "Your OS Image"

     # ECS type (예 : ecs.n4.large)
      ecs_type = "Your ECS Type"

     # EIP 수량 선택 (필요하지 않을 경우 삭제)
     # eip_count = ""

     # System disk size 선택 (기본값 window - 40GB, linux - 20GB)
      disk_size = "40"

     # vswitch 정보 (vpc 생성 시 map에서 등록한 리전 순으로 0,1)
      ecs_vswitch_id = lookup(module.dev_vpc.public_info_map, local.azs[0])

     # SG 정보
      ecs_sg_id = module.was_sg.sg_id
    }
    ```

    - azs : local에 기입한 내용 중 리전을 선택. 첫번째 라면 [0], 두번째 값이면 [1] 순으로 기입
    - ecs_count : 동일한 용도의 ecs의 수량을 선택
    - ecs_name : ecs의 이름을 기입. 수량이 2개일 경우 "name-01", "name-02" 순으로 순번이 기입
    - ecs_password : ecs의 암호 기입
    - ecs_image : ecs의 이미지를 기입. 이미지를 안다면 직접 기입해도 무관
    - ecs_type : ecs의 스펙을 기입. 문서에서 원하는 타입을 선택 후 기입
    - eip_count : ecs에 eip를 연동하고자 한다면 기입. 단 필요 없다면 "" 으로 기입
    - disk_size : system disk가 사용할 용량을 기입. 추후에 데이타 디스크도 추가 예정
    - ecs_vswitch_id : 사용하고자 하는 vswitch의 리전을 변경. local.azs[0] or "cn-shanghai-a"
    - ecs_sg_id : 미리 생성한 용도의 보안그룹을 선택.  was_sg - 이름을 보안그룹 이름으로 변경

ECS 생성 code 참고 : [modules/ecs 폴더 참고](https://github.com/seodea/terraform-alicloud-module/tree/main/modules/ecs)

### STEP 1.4 SLB 인스턴스 생성

SLB 인스턴스를 생성을 합니다.

- Product 서비스를 위한 SLB 생성과 Internal SLB 생성을 합니다. 생성 후 SLB의 Listener를 구성을 하기 위한 변수도 등록을 하면 모두 구성이 가능합니다.

- 모듈 변수 Code

    ```
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

        # TCP의 경우 sticky session setting, "on", "server"
        #sticky_session      = "on"
        #sticky_session_type = "server"

        # http의 경우 sticky session setting, "on", "insert"
        #sticky_session      = "on"
        #sticky_session_type = "insert"
        #cookie_timeout      = "86400"

        gzip                = "false"
        #retrive_slb_ip      = "true"
        #retrive_slb_id      = "false"
        #retrive_slb_proto   = "true"
        persistence_timeout = "5"
      }

      // x_forwarded_for will apply to all of listeners if it is not set in the listeners
      x_forwarded_for = {
        retrive_slb_ip    = "true"
        retrive_slb_id    = "false"
        retrive_slb_proto = "true"
      }

      ssl_certificates = {
        #tls_cipher_policy = "tls_cipher_policy_1_0"
      }
    }

    module "dev_internal_slb" {

      source  = "../modules/slb"

      #####
      #  SLB instance
      #####
      name = "Your internal slb Name"
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

        # TCP의 경우 sticky session setting, "on", "server"
        #sticky_session      = "on"
        #sticky_session_type = "server"

        # http의 경우 sticky session setting, "on", "insert"
        #sticky_session      = "on"
        #sticky_session_type = "insert"
        #cookie_timeout      = "86400"

        gzip                = "false"
        #retrive_slb_ip      = "true"
        #retrive_slb_id      = "false"
        #retrive_slb_proto   = "true"
        persistence_timeout = "5"
      }

      // x_forwarded_for will apply to all of listeners if it is not set in the listeners
      x_forwarded_for = {
        retrive_slb_ip    = "true"
        retrive_slb_id    = "false"
        retrive_slb_proto = "true"
      }

      ssl_certificates = {
        #tls_cipher_policy = "tls_cipher_policy_1_0"
      }
    }
    ```

    - name : slb에 사용할 이름 기입
    - internet_charge_type : 기본값인 pay-by-traffic, 변경이 필요할 경우만 변경
    - address_type : 외부, 내부용 중 선택
    - vswitch_id : 내부용일때만 기입
    - specification : slb의 스펙을 기입
    - master_zone_id : 메인 slb zone을 기입
    - slave_zone_id : 스탠바이 slb zone을 기입
    - listeners : slb의 리스너 생성 변수 기입
        - backend_port : 서버와 연결될 port 기입
        - frontend_port : 외부에서 접속할 port 기입
        - protocol : tcp, ump, http, https 중 선택
        - scheduler : 세션 분기에 대한 옵션 선택 "wrr"의 경우 round-robin
        - healthy_threshold  : 상태 확인에 대한 빈도 기입
        - gzip : gzip 활성화에 대한 옵션 기입
        - health_check_type : 상태 확인 시 체크할 타입 선택. tcp - tcp, http - http 로 설정 
        **(내용하번더 확인)**
    - health_check : 헬스체크 변수 기입
        - health_check : 사용여부 기입. 사용 하지않을 경우 "false"
        - health_check_type : tcp or http 중 기입
        - healthy_threshold : 정상여부에 대한 횟수 기입
        - unhealthy_threshold : 비정장여부에 대한 횟수 기입
        - health_check_timeout : 헬스체크 타임아웃 시간 기입
        - health_check_interval : 헬스체크 인터벌 기입
        - health_check_connect_port : 헬스체크용 포트 기입
        - health_check_uri : 기본값 "/" 로 설정. 단, 원하는 특별한 경로가 있을 경우 기입
        - health_check_http_code : 헬스체크 페이지 코드 기입
    - advanced_setting : 고급 기능에 대한 변수 기입
        - sticky_session : sticky session 사용 여부 기입
        - sticky_session_type : sticky_session 타입 기입
        - gzip : gzip 사용 여부 선택
        - persistence_timeout : 몇초동안 유지를 할지에 대한 설정 기입
- x_forwarded_for : x_forwarded_for 기능 설정 변수 기입
    - retrive_slb_ip : x_forwarded_for 관련된 기능 사용여부 기입
    - retrive_slb_id : x_forwarded_for 관련된 기능 사용여부 기입
    - retrive_slb_proto : x_forwarded_for 관련된 기능 사용여부 기입
- ssl_certificates : 인증서 사용관련 변수 기입
    - tls_cipher_policy : 기존에 등록한 인증서 있을 경우 선택

SLB 생성 code 참고 : [modules/slb 폴더 참고](https://github.com/seodea/terraform-alicloud-module/tree/main/modules/slb)

### STEP 1.5 RDS 인스턴스 생성

해당 가이드에서는 DB를 관리형 Database로 사용하려고 합니다. Alibaba Clooud가 제공하는 관리형 Database중 Mysql을 사용을 합니다. 단, 해당 인스턴스 생성 모듈화 코드에는 오직 MySQL만 생성이 가능합니다. RDS 생성 및 백업 정책까지 적용이 가능하며, 백업 정책은 옵션입니다.


- 모듈 변수 Code

    ```
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
    ```

    - engine : DB 엔진 기입
    - engine_version : DB 버전 기입
    - instance_type : DB 스펙 기입
    - instance_storage : DB 저장소 용량 기입
    - instance_charge_type : 가격 정책에 대한 내용 기입
    - instance_name : DB 이름 기입
    - security_group_ids : DB에서 사용할 보안그룹 등록 (필수 x)
    - vswitch_id : DB에서 사용한 vswitch를 local.azs[0]로 선택
    - security_ips : DB에 접속이 가능한 네트워크 설정. local."subnet" 으로 선택
    - master_zone : 마스터 zone 선택
    - slave_zone : 스탠바이 zone 선택 원하는 zone이 따로없을 경우, "auto"사용가능
    - 백업 여부 설정
        - preferred_backup_period : 백업 날짜를 ["",""] 형태로 기입
        - preferred_backup_time : 백업 시간은 UTC 기준으로 기입 (ex :15:00z-16:00z일 경우 한국시간 00:00-01:00)
        - backup_retention_period : 백업 유지 기간 설정
        - log_backup_retention_period : 로그 백업 기간 설정
        - enable_backup_log : 백업 로그 활성화 여부 기입
    - 외부 접속 여부 설정
        - allocate_public_connection : public endpoint 사용여부 기입
        - port : 외부에서 접속할 포트 기입. 기본값은 DB engine과 동일
        - connection_prefix : 연결을 위한 prefix 기입
    - DB 계정 설정
        - type : 계정 유형 설정
        - privilege : 권한 설정
        - account_name : 계정 이름 기입
        - password : 암호 기입
    - database 생성 설정
        - name : database 이름 기입
        - character_set : 사용할 character_set 선택
        - description : 설명 기입

RDS 생성 code 참고 : [modules/rds 폴더 참고](https://github.com/seodea/terraform-alicloud-module/tree/main/modules/rds)

## STEP 2. Module을 이용하여 배포한 서비스 확인

STEP 1에서 Module을 이용해서 배포한 서비스를 하나씩 확인을 하며, 원하는데로 서비스가 구성이되었는지 확인을 합니다. 

### STEP 2.1. Module 실행

Terraform Module을 실행을 하려면 modules과 test code를 다운을 받아야합니다. 
linux의 경우 아래와 같이 다운로드 후 사용을 합니다.
```
wget https://github.com/seodea/terraform-alicloud-module/archive/refs/heads/main.zip
unzip main.zip
cd terraform-alicloud-module-main/02.test_code/
```

해당 폴더에 있는 main_code.tf에는 바로 사용이 가능하게 변수값이 기입이 되어있습니다.
만약, 수정이 필요하신 부분이 있으면 최소한으로 수정으로 바로 사용이 가능합니다.


- terraform plan을 진행합니다.

```
[root@sdh-tf-vm dev]# terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

module.was_instances.data.alicloud_instance_types.default: Refreshing state...
module.web_instances.data.alicloud_instance_types.default: Refreshing state...
module.web_instances.data.alicloud_images.images: Refreshing state...
module.was_instances.data.alicloud_images.images: Refreshing state...

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.dev_internal_slb.alicloud_slb.slb_instance will be created
  + resource "alicloud_slb" "slb_instance" {
      + address              = (known after apply)
      + address_type         = "intranet"
      + delete_protection    = "off"
      + id                   = (known after apply)
      + instance_charge_type = "PostPaid"
      + internet             = (known after apply)
      + master_zone_id       = "cn-shanghai-a"
      + name                 = "internal-slb"
      + resource_group_id    = (known after apply)
      + slave_zone_id        = "cn-shanghai-b"
      + specification        = "slb.s1.small"
      + vswitch_id           = (known after apply)
    }

  # module.dev_internal_slb.alicloud_slb_listener.this[0] will be created
  + resource "alicloud_slb_listener" "this" {
      + acl_status                   = "off"
      + backend_port                 = 1234
      + delete_protection_validation = false

...

Plan: 42 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

이상이 없을 경우, 생성이나 변경이 되는 내용에 대해서 나열이 됩니다.

VPC, vSwitch, ECS, SG, SLB, RDS를 모두 생성을 하는데 총 42개가 추가가 된다는 내용입니다.

- terraform apply

서비스 생성을 하기위해서는 terraform apply를 진행해야 합니다. "yes"를 기입을 하면 설치가 진행됩니다.

```
...

Plan: 42 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
```

- 완료

정상적으로 설치가 끝나면, output.tf에 기입한 내용이 출력이되면서 확인이 가능합니다. output.tf 파일에 보다 자세한 내용을 기입을 하면 console에 접속을 하지 않더라도 바로 접속이 가능합니다.

```
...

module.mysql.alicloud_db_account_privilege.this[0]: Creating...
module.mysql.alicloud_db_backup_policy.this: Creation complete after 4s [id=rm-6nn14hi97t3q6uy41]
module.mysql.alicloud_db_account_privilege.this[0]: Creation complete after 2s [id=rm-6nn14hi97t3q6uy41:megazone:ReadWrite]

Apply complete! Resources: 42 added, 0 changed, 0 destroyed.

Outputs:

db_info = {
  "dev_rds_info" = {
    "dev-rds" = "rm-6nn14hi97t3q6uy41"
  }
}
public_sg_info = {
  "sg_id" = "sg-uf60ox6w6y6nu1tawwby"
}
vpc_info = {
  "database_cidr" = "172.16.2.0/24,172.16.102.0/24"
  "database_subnet_names" = "tf-dev-private-VS-cn-shanghai-a,tf-dev-private-VS-cn-shanghai-b"
  "db_info_map" = {
    "cn-shanghai-a" = "vsw-uf6djygf20uom2e2p3bpe"
    "cn-shanghai-b" = "vsw-uf600qsqqhgjsh92id2pu"
  }
  "private_cidr" = "172.16.1.0/24,172.16.101.0/24"
  "private_info_map" = {
    "cn-shanghai-a" = "vsw-uf6aef4bgrt8inqll6p84"
    "cn-shanghai-b" = "vsw-uf6x9bzs0umxwb2cml6am"
  }
  "public_cidr" = "172.16.0.0/24,172.16.100.0/24"
  "public_info_map" = {
    "cn-shanghai-a" = "vsw-uf6povif61u381tbhqtk9"
    "cn-shanghai-b" = "vsw-uf6fyue70yoi1oyj149al"
  }
  "vpc_cidr_block" = "172.16.0.0/16"
  "vpc_id" = "vpc-uf64u85w98gbz19sqecyc"
}
was_instances = {
  "ecs_ids" = "i-uf68dmrj7zr0of8lkv3d,i-uf65dnhz2h1irgcsbhll"
  "eip_addresses" = ""
  "hostname_list" = "was-01,was-02"
}
was_sg_info = {
  "sg_id" = "sg-uf6alfqlbdk6ixvbi47y"
}
web_instances = {
  "ecs_ids" = "i-uf636kjjx58o39mzyp83,i-uf6i1r3ycwoiabd94bbp"
  "eip_addresses" = "106.14.251.20,106.14.240.47"
  "hostname_list" = "web-01,web-02"
}
```

모두 정상적으로 설치가 되었습니다.

**END**

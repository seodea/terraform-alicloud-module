provider "alicloud" {
  access_key = "LTAI4GCvMHe8CS3YnkskniBe"
  secret_key = "9PAwvTNeqsp5A2WC6SfxMRLPhMN7IP"
  region     = "cn-shanghai"
}

#provider "alicloud" {
#  region     = "cn-hongkong"
#  alias = "hongkong"
#  access_key = "LTAI4GH6Dyn5rSnxXq1PRkLG"
#  secret_key = "C43JOulbSOUQNaplG8DkPRmmqi9geS"
#}

# 다른 위치에 tfstate 파일 저장을 위한 원격저장소 지정
#terraform {
#  backend "oss" {
#    bucket = "sdh-oss-hk"
#    prefix   = "terraform/status"
#    key   = "terraform.tfstate"
#    region = "cn-hongkong"
#    access_key = "YOUR ACCESS KEY"
#    secret_key = "YOUR SECRET KEY"
#  }
#}

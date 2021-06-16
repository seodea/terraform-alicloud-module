# ecs.tf

data "alicloud_instance_types" "default" {
  instance_type_family = "ecs.n1"
  availability_zone = var.azs
  cpu_core_count       = 1
  memory_size          = 2
}

# ECS Image 선택 (^centos_7의 경우 Centos 7 버전중 최슨으로 전달) 
data "alicloud_images" "images" {
  most_recent = true
  owners     = "system"
  name_regex = var.ecs_image
}

resource "alicloud_instance" "instance" {
  
  instance_name = var.ecs_count < 2 ? var.ecs_name : format(
    "%s-%s",
    var.ecs_name,
    format(var.number_format, count.index + 1),
  )
  host_name = var.ecs_count < 2 ? var.ecs_name : format(
    "%s-%s",
    var.ecs_name,
    format(var.number_format, count.index + 1),
  )

  image_id        = data.alicloud_images.images.ids.0
  instance_type   = var.ecs_type == "" ? data.alicloud_instance_types.default.instance_types[0].id : var.ecs_type
  count           = var.ecs_count
  security_groups = [var.ecs_sg_id]
  vswitch_id      = var.ecs_vswitch_id

  #internet_charge_type       = var.internet_charge_type # Optional 
  #internet_max_bandwidth_out = var.internet_max_bandwidth_out #Optional 0 to 100, default "0"
  #internet_max_bandwidth_in  = var.internet_max_bandwidth_in #Optional 0 to 200, default "0"
  password = var.ecs_password

  instance_charge_type = var.instance_charge_type #Optional, default "Postpaid"
  system_disk_category = var.system_disk_category #ForceNew, ephemeral_ssd, cloud_efficiency, cloud_ssd, cloud_essd, cloud, default "cloud_efficiency"
  
  status = "Stopped"  

  tags = {
    role = var.role
  }
}


# EIP bind to ecs
resource "alicloud_eip" "eip" {
  count = var.eip_count
  name  = format("%s-%s-eip",var.ecs_name, count.index + 1)
  bandwidth = 200
}

resource "alicloud_eip_association" "ecs_eip" {
  count = var.eip_count  >= 1 ? var.eip_count : 0 

  instance_id   = alicloud_instance.instance[count.index].id
  allocation_id = alicloud_eip.eip[count.index].id
}



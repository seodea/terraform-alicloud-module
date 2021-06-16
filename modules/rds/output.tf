#output "rds_id"{
#  value = join(",", alicloud_db_instance.rds_instance.*.id)
#}

output "dev_rds_info" {

  value = zipmap(alicloud_db_instance.rds_instance.*.instance_name, alicloud_db_instance.rds_instance.*.id) 

}


#output "sql_type_info"{
#  value = data.alicloud_db_instance_classes.default
#}

#output "local_info"{
#  value = local.test
#}

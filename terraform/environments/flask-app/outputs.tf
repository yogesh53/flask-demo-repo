
output "alb_security_group_id" {
  value = module.security_groups.alb_security_group_id
}
output "eks_node_security_group_id" {
  value = module.security_groups.eks_node_security_group_id
}
output "rds_security_group_id" {
  value = module.security_groups.rds_security_group_id
}
output "db_instance_endpoint"{
    value = module.rds.db_instance_endpoint
}
output "db_instance_address"{
    value = module.rds.db_instance_address
}
output "db_name"{
    value = module.rds.db_name
}
output "port"{
    value = module.rds.port
}
output "repository_url"{
  value = module.ecr.repository_url
}
output "cluster_name"{
  value = module.eks.cluster_name
}

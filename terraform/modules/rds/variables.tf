variable "environment" {
  type = string
}
variable "database_subnet_ids" {
  type = list(string)
}
variable "security_group_id" {
  type = string
}
variable "db_name" {
  type    = string
  default = "flaskdb"
}
variable "db_username" {
  type    = string
  default = "flaskadmin"
}
variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}
variable "engine_version" {
  type    = string
  default = "16"
}
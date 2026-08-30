variable "aws_region" {
  description = "Region where aws resources are created"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "uat"
}
variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}
variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}
variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
}
variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
}
variable "database_subnet_cidrs" {
  description = "Database subnet CIDRs"
  type        = list(string)
}
variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
  default     = true
}
variable "node_min_size" {
  description = "Minimum node size"
  type        = number
  default     = 1
}
variable "node_max_size" {
  description = "Maximum node size"
  type        = number
  default     = 4
}
variable "node_desired_size" {
  description = "Desired node size"
  type        = number
  default     = 1
}
variable "kubernetes_version" {
  description = "kubernetes Version"
  type        = string
}
variable "cluster_name" {
  type = string
}
variable "node_instance_types" {
  type = list(string)
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

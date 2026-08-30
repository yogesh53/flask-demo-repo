aws_region  = "ap-south-1"
environment = "uat"
vpc_cidr    = "10.0.0.0/16"
availability_zones = [
  "ap-south-1a", "ap-south-1b"
]
public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]
private_subnet_cidrs = [
  "10.0.11.0/24",
  "10.0.12.0/24"
]
database_subnet_cidrs = [
  "10.0.21.0/24",
  "10.0.22.0/24"
]
enable_nat_gateway  = true
node_min_size       = 2
node_max_size       = 3
node_desired_size   = 2
kubernetes_version  = 1.35
cluster_name  = "flask"
node_instance_types = ["t3.large"]
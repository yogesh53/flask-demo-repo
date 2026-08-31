data "aws_caller_identity" "current" {}
data "aws_iam_role" "github_actions" {
  name = "gitbubaction-ecr-role"
}
module "vpc" {
  source                = "../../modules/vpc"
  environment           = var.environment
  vpc_cidr              = var.vpc_cidr
  availability_zones    = var.availability_zones
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  enable_nat_gateway    = var.enable_nat_gateway
}
module "security_groups" {
  source      = "../../modules/security-groups"
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.25.0"

  name = var.cluster_name
  kubernetes_version = var.kubernetes_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
   
  endpoint_public_access  = true
  enable_cluster_creator_admin_permissions = true

  addons = {
    coredns                = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    amazon-cloudwatch-observability = {
      before_compute = true

      pod_identity_association = [
        {
         role_arn        = aws_iam_role.cloudwatch_addon.arn
        service_account = "cloudwatch-agent"
    }
      ]
  }

    kube-proxy             = {}
    vpc-cni                = {
      before_compute = true
    }
  
  }
    access_entries = {
     github_actions = {
      principal_arn = data.aws_iam_role.github_actions.arn

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

          access_scope = {
          type = "cluster"
        }
      }
    }
  }
}
  eks_managed_node_groups = {
    application = {
      name = "${var.cluster_name}-nodes"

      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size

      instance_types = var.node_instance_types
      ami_type       = "AL2023_x86_64_STANDARD"

      vpc_security_group_ids = [
        module.security_groups.eks_node_security_group_id
      ]
    }
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

module "rds"{
  source = "../../modules/rds"
  environment = var.environment
  database_subnet_ids = module.vpc.database_subnet_ids
  security_group_id = module.security_groups.rds_security_group_id
  db_name = var.db_name
  db_username = var.db_username
  db_instance_class = var.db_instance_class
  engine_version = "16"
}

module "ecr"{
  source = "../../modules/ecr"
  environment = var.environment
}

module "eso"{
  source = "../../modules/eso"
  cluster_name = module.eks.cluster_name
  environment = var.environment
  rds_secret_arn = module.rds.secret_arn
}

resource "aws_s3_bucket" "alb_logs" {
  bucket        = "flask-alb-logs-demo"
  force_destroy = true
}
resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "logdelivery.elasticloadbalancing.amazonaws.com" }
      Action    = "s3:PutObject"
      Resource  = "arn:aws:s3:::flask-alb-logs-demo/AWSLogs/767397770552/*"
    }]
  })
}
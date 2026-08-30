resource "aws_security_group" "alb"{
    name = "${var.environment}-alb-sg"
    description = "Security group for ALB"
    vpc_id = var.vpc_id
    tags = {
        Name = "${var.environment}-alb-sg"
    }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http"{
    security_group_id = aws_security_group.alb.id
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 80
    to_port = 80
    ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "alb_https"{
    security_group_id = aws_security_group.alb.id
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 443
    to_port = 443
    ip_protocol = "tcp"
}
resource "aws_vpc_security_group_egress_rule" "alb_all" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  description = "Allow outbound traffic from ALB"
}
resource "aws_security_group" "eks_nodes"{
    name = "${var.environment}-eks-node-sg"
    description = "Security group for EKS Nodes"
    vpc_id = var.vpc_id
    tags = {
        Name = "${var.environment}-eks-node-sg"
    }
}
resource "aws_vpc_security_group_ingress_rule" "eks_from_alb"{
    security_group_id = aws_security_group.eks_nodes.id
    referenced_security_group_id = aws_security_group.alb.id
    from_port = 5000
    to_port = 5000
    ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "eks_all"{
    security_group_id = aws_security_group.eks_nodes.id
    cidr_ipv4   = "0.0.0.0/0"
    ip_protocol = "-1"
}
resource "aws_security_group" "rds"{
    name = "${var.environment}-rds-sg"
    vpc_id = var.vpc_id
    description = "Allow accesss to RDS"
    tags = {
        Name = "${var.environment}-rds-sg"
    }
}
resource "aws_vpc_security_group_ingress_rule" "rds_postgress"{
    security_group_id = aws_security_group.rds.id
    referenced_security_group_id = aws_security_group.eks_nodes.id
    from_port = 5432
    to_port = 5432
    ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "rds_all" {
  security_group_id = aws_security_group.rds.id
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}
resource "aws_ecr_repository" "example"{
    name = "flask"
    image_tag_mutability = "IMMUTABLE"
    image_scanning_configuration {
        scan_on_push = true
    }
    tags = {
    Name        = "${var.environment}-ecr"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
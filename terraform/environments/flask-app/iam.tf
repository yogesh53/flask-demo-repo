resource "aws_iam_role" "cloudwatch_addon"{
    name = "${var.cluster_name}-cloudwatch-observability"
    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "pods.eks.amazonaws.com"
        }

        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

}

resource "aws_iam_role_policy_attachment" "cloudwatch_addon_policy" {
  role       = aws_iam_role.cloudwatch_addon.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
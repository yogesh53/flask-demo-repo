data "aws_iam_policy_document" "eso_secret"{
    statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]

    resources = [
      var.rds_secret_arn
    ]
  }
}
resource "aws_iam_role" "eso"{
    name = "${var.cluster_name}-eso-role"
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
}

resource "aws_iam_role_policy" "eso"{
    name = "${var.cluster_name}-eso-policy"
    role = aws_iam_role.eso.id
    policy = data.aws_iam_policy_document.eso_secret.json
}
resource "aws_eks_pod_identity_association" "eso"{
    cluster_name = var.cluster_name
    namespace = "external-secrets"
    service_account = "external-secrets"
    role_arn = aws_iam_role.eso.arn
}
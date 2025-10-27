# # terraform/data.tf

# Search the ECR Repository
data "aws_ecr_repository" "app" {
  name = "mini-erp"
}

# Search IAM Role for CodeBuild
data "aws_iam_role" "codebuild_role" {
  name = "mini-erp-codebuild-role"
}

# Search AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# -----------------------------------------------------
# Reference to RDS Secret #
# -----------------------------------------------------
data "aws_secretsmanager_secret" "rds_db_secret" {
  arn  = var.db_secret_arn
}

data "aws_secretsmanager_secret_version" "rds_db_secret_version" {
  secret_id = data.aws_secretsmanager_secret.rds_db_secret.id
}

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

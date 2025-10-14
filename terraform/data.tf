# # terraform/data.tf

# Search the ECR Repository
data "aws_ecr_repository" "app" {
  name = "mini-erp"
}

# Search IAM Role for CodeBuild
data "aws_iam_role" "codebuild_role" {
  name = "mini-erp-codebuild-role"
}

# # Search the default VPC (or your existing VPC)
# data "aws_vpc" "default" {
#   filter {
#     name = "is-default"
#     values = [true]
#   }
# }
#
# # Search the subnets (sub-networks) of your VPC (for Fargate)
# data "aws_subnets" "default" {
#   filter {
#     name = "vpc-id"
#     values = [data.aws_vpc.default.id]
#   }
# }

# Search AZs
data "aws_availability_zones" "available" {
  state = "available"
}
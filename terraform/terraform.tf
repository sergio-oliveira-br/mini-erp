# terraform/terraform.tf
# Reference: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-create

# The terraform {} block configures Terraform itself,
# including which providers to install,
# and which version of Terraform to use to provision your infrastructure.
# Using a consistent file structure makes maintaining your Terraform projects easier,
# so we recommend configuring your Terraform block in a dedicated terraform.tf file.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = "~> 1.7"
}

# Setting the AWS provider
provider "aws" {
  region = "eu-west-1"
}
# main.tf
# Reference: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-create

# -----------------------------------------------------
# 1. ARTIFACT BUCKET - CodePipeline will store files
# -----------------------------------------------------
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "artifact_bucket" {
  bucket = "mini-erp-artifacts-${data.aws_caller_identity.current.account_id}"
}



# -----------------------------------------------------
# 2. CODEBUILD PROJECT (The executer do Build do Docker)
# -----------------------------------------------------
resource "aws_codebuild_project" "app_build" {
  name           = "${var.project_name}-build"
  service_role   = data.aws_iam_role.codebuild_role.arn
  build_timeout  = "10"

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    # Injects to URL ECR (searched for data.tf) on build environment
    environment_variable {
      name  = "ECR_REPO_URI"
      value = data.aws_ecr_repository.app.repository_url
    }
  }
  source { type = "CODEPIPELINE" }
  artifacts { type = "CODEPIPELINE" }
}


# -----------------------------------------------------
# 3. CODEPIPELINE ROLE (Permission for or CodePipeline Orchestrate)
# -----------------------------------------------------
resource "aws_iam_role" "codepipeline_role" {
  name = "mini-erp-codepipeline-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      },
    ]
  })
}

# CodePipeline permissions (Allows you to interact with S3, CodeBuild and GitHub)
resource "aws_iam_role_policy" "codepipeline_policy" {
  role = aws_iam_role.codepipeline_role.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:Get*",
          "s3:List*",
          "s3:PutObject",
          "s3:DeleteObject",
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds",
          "codestar-connections:UseConnection"
        ],
        Resource = "*"
      },
    ]
  })
}



# -----------------------------------------------------
# 4. CODEPIPELINE (orchestrator)
# -----------------------------------------------------
resource "aws_codepipeline" "app_pipeline" {
  name     = "mini-erp-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.artifact_bucket.id
  }

  # --- PHASE 1: SOURCE (GITHUB) ---
  stage {
    name = "Source"
    action {
      name             = "SourceAction"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = "arn:aws:codeconnections:eu-west-1:905418423035:connection/80aac56e-4255-4632-8ed4-33bb0e127d86"
        FullRepositoryId = "sergio-oliveira-br/mini-erp"
        BranchName       = "main"
      }
    }
  }

  # --- PHASE 2: BUILD (CODEBUILD) ---
  stage {
    name = "Build"
    action {
      name             = "BuildAction"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.app_build.name
      }
    }
  }
}

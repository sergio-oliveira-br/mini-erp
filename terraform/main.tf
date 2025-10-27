# terraform/main.tf
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

  # --- PHASE 3: DEPLOY (ECS) ---
  stage {
    name = "Deploy"
    action {
      name            = "DeployAction"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ClusterName = aws_ecs_cluster.mini_erp_cluster.name
        ServiceName = aws_ecs_service.app.name
        FileName    = "imagedefinitions.json"
      }
    }
  }
}

# -----------------------------------------------------
# 5.  ECS CLUSTER VPC, SUBNETS e INTERNET GATEWAY
# -----------------------------------------------------

resource "aws_ecs_cluster" "mini_erp_cluster" {
  name = "mini-erp-cluster"
}

# 5.1. VPC
resource "aws_vpc" "app_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# 5.2. Internet Gateway
resource "aws_internet_gateway" "app_igw" {
  vpc_id = aws_vpc.app_vpc.id
  tags = {
    Name = "${var.project_name}-igw"
  }
}

# 5.3. Subnets Públicas (mínimo de 2 para Fargate)
resource "aws_subnet" "public" {
  count             = 2 # Cria duas subnets
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
  }
}

# 5.4. Tabela de Roteamento Pública (para acesso à Internet)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_igw.id
  }
}

# 5.5. Associação da Tabela de Roteamento às Subnets
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


# -----------------------------------------------------
# 6. IAM Task Execution Role
# -----------------------------------------------------
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "mini-erp-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# -----------------------------------------------------
# 7. ECS TASK DEFINITION (Blueprint do Container)
# -----------------------------------------------------
resource "aws_ecs_task_definition" "app" {
  family                   = "mini-erp-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "mini-erp",
      image     = "placeholder",
      cpu       = 256,
      memory    = 512,
      essential = true,
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ],
      environment = [
        {
          name  = "SPRING_PROFILES_ACTIVE"
          value = "prod"
        },
        {
          name  = "JDBC_DATABASE_URL"
          value = "jdbc:postgresql://minierp-postgres-db.cdo6c2kyu0bn.eu-west-1.rds.amazonaws.com:5432/postgres"
        },
      ],

      # Secret Variables - from Secret Manager
      secrets = [
        {
          name      = "DB_USERNAME"
          valueFrom = "arn:aws:secretsmanager:eu-west-1:905418423035:secret:rds!db-b07c2336-0555-4661-b9b8-60048ced9ef3-qmVsXU:username"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "arn:aws:secretsmanager:eu-west-1:905418423035:secret:rds!db-b07c2336-0555-4661-b9b8-60048ced9ef3-qmVsXU:password"
        }
      ]
      
      logConfiguration: {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/mini-erp-task",
          "awslogs-region": "eu-west-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ])
}



# -----------------------------------------------------
# 8. ECS SERVICE (Keeps the task running)
# -----------------------------------------------------
resource "aws_ecs_service" "app" {
  name            = "mini-erp-service"
  cluster         = aws_ecs_cluster.mini_erp_cluster.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = aws_subnet.public[*].id
    security_groups = [aws_security_group.allow_http.id]
    assign_public_ip = true
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count, load_balancer]
  }
}


resource "aws_security_group" "allow_http" {
  name        = "mini-erp-sg"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    description = "HTTP 8080 from internet"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

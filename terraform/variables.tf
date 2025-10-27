# terraform/variables.tf

variable "project_name" {
  description = "Project Name"
  type        = string
  default     = "mini-erp"
}

variable "github_repo_owner" {
  description = "My GitHub username"
  type        = string
  default     = "sergio-oliveira-br"
}

variable "github_repo_name" {
  description = "My GitHub repository"
  type        = string
  default     = "mini-erp"
}

variable "environment" {
  description = "deployment environment"
  type        = string
  default     = "dev"
}

# -----------------------------------------------------
# DB - Postgres (RDS) - via Secrets Manager
# -----------------------------------------------------

variable "db_secret_arn" {
  description = "Secrete ARN - Database"
  type = string
  default = "arn:aws:secretsmanager:eu-west-1:905418423035:secret:rds!db-dd76ce59-3689-414d-974e-3bba8525c985-GEBCd4"
}

variable "db_secret_name" {
  description = "Secrete Name - Database"
  type        = string
  default     = "rds!db-dd76ce59-3689-414d-974e-3bba8525c985"
}
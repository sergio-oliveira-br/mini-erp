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
# ecr/main.tf

provider "aws" {
  region = var.aws_region
}

# ECR Repository
resource "aws_ecr_repository" "app_ecr_repo" {
  name = var.ecr_repository_name
  
  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      tags,
    ]
  }
}

output "repository_url" {
  value = aws_ecr_repository.app_ecr_repo.repository_url
}

output "repository_name" {
  value = aws_ecr_repository.app_ecr_repo.name
}
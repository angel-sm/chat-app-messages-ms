# lambda/main.tf

provider "aws" {
  region = var.aws_region
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.lambda_function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  
  # Prevent destruction and ignore certain changes
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      assume_role_policy,
      description,
      tags,
    ]
  }
}

# Attach policies to IAM Role
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Function
resource "aws_lambda_function" "app_lambda" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_role.arn
  timeout       = 30
  memory_size   = 512
  package_type  = "Image"
  image_uri     = var.image_uri

  handler = "main"

  environment {
    variables = {
      NODE_ENV = var.environment
    }
  }
  
  lifecycle {
    ignore_changes = [
      tags,
      description,
      reserved_concurrent_executions,
    ]
  }

  depends_on = [aws_iam_role.lambda_role]
}

output "lambda_function_name" {
  value = aws_lambda_function.app_lambda.function_name
}

output "lambda_invoke_arn" {
  value = aws_lambda_function.app_lambda.invoke_arn
}
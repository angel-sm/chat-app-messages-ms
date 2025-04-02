# main.tf

provider "aws" {
  region = var.aws_region
}

# ECR Repository - already exists
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

# IAM Role for Lambda - already exists
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
      # Ignore changes that might have been made outside Terraform
      assume_role_policy,
      description,
      tags,
    ]
  }
}

# Attach policies to IAM Role if not already attached
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
  image_uri     = "${aws_ecr_repository.app_ecr_repo.repository_url}:latest"

  environment {
    variables = {
      NODE_ENV = var.environment
    }
  }
  
  # Focus on updating the image_uri
  lifecycle {
    ignore_changes = [
      # Ignore changes to these attributes since we're mainly concerned with updating the image
      tags,
      description,
      reserved_concurrent_executions,
    ]
  }
}

# API Gateway
resource "aws_apigatewayv2_api" "lambda_api" {
  name          = "${var.lambda_function_name}-gateway"
  protocol_type = "HTTP"
  
  lifecycle {
    ignore_changes = [tags, cors_configuration]
  }
}

resource "aws_apigatewayv2_stage" "lambda_stage" {
  api_id      = aws_apigatewayv2_api.lambda_api.id
  name        = var.environment
  auto_deploy = true
  
  lifecycle {
    ignore_changes = [default_route_settings, tags, deployment_id]
  }
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.lambda_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.app_lambda.invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "lambda_route" {
  api_id    = aws_apigatewayv2_api.lambda_api.id
  route_key = "GET /"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.app_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda_api.execution_arn}/*/*"
}

# Output the API Gateway URL
output "api_gateway_url" {
  value = "${aws_apigatewayv2_stage.lambda_stage.invoke_url}"
}
# api-gateway/main.tf

provider "aws" {
  region = var.aws_region
}

# Reference existing Lambda function
data "aws_lambda_function" "existing_lambda" {
  function_name = var.lambda_function_name
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
  integration_uri    = data.aws_lambda_function.existing_lambda.invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "lambda_route" {
  api_id    = aws_apigatewayv2_api.lambda_api.id
  route_key = "GET /messages"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.existing_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda_api.execution_arn}/*/*"
  
  depends_on = [
    aws_apigatewayv2_stage.lambda_stage,
    aws_apigatewayv2_route.lambda_route
  ]
}

output "api_gateway_url" {
  value = "${aws_apigatewayv2_stage.lambda_stage.invoke_url}"
}
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  region = var.aws_region
}

// Create the S3 bucket using a random pet name (Terraform function).
resource "random_pet" "lambda_bucket_name" {
  prefix = "test-functions"
  length = 4
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = random_pet.lambda_bucket_name.id
}

resource "aws_s3_bucket_ownership_controls" "lambda_bucket" {
  bucket = aws_s3_bucket.lambda_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "lambda_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.lambda_bucket]

  bucket = aws_s3_bucket.lambda_bucket.id
  acl    = "private"
}

// Package the lambda function at /nodejs-app/index.js and copy to the S3 bucket.
data "archive_file" "lambda_nodejs_app" {
  type = "zip"

  source_dir  = "${path.module}/nodejs-app"
  output_path = "${path.module}/nodejs-app.zip"
}

resource "aws_s3_object" "lambda_nodejs_app" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "nodejs-app.zip"
  source = data.archive_file.lambda_nodejs_app.output_path

  etag = filemd5(data.archive_file.lambda_nodejs_app.output_path)
}

// Configures the Lambda function to use the bucket object containing the function code, sets the node.js version, etc.
resource "aws_lambda_function" "nodejs_app" {
  function_name = "NodeJsApp"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_nodejs_app.key

  runtime = "nodejs22.x"
  handler = "index.handler"

  source_code_hash = data.archive_file.lambda_nodejs_app.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}

// Defines a log group to store log messages from the Lambda function for 30 days.
resource "aws_cloudwatch_log_group" "nodejs_app" {
  name = "/aws/lambda/${aws_lambda_function.nodejs_app.function_name}"

  retention_in_days = 30
}

// Defines an IAM role that allows Lambda to access resources in your AWS account.
resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

// Create API gateway

// Defines a name for the API Gateway and sets the protocol to HTTP.
resource "aws_apigatewayv2_api" "lambda" {
  name          = "serverless_lambda_gw"
  protocol_type = "HTTP"
}

// Sets up application stages for the API Gateway - such as "Test", "Staging", and "Production".
// The example configuration defines a single stage, with access logging enabled.
resource "aws_apigatewayv2_stage" "lambda" {
  api_id = aws_apigatewayv2_api.lambda.id

  name        = "nodejs_app"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

// Configures the API Gateway to use the Lambda function.
resource "aws_apigatewayv2_integration" "nodejs_app" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = aws_lambda_function.nodejs_app.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

// Maps an HTTP request to a target, in this case your Lambda function.
resource "aws_apigatewayv2_route" "nodejs_app" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "GET /index"
  target    = "integrations/${aws_apigatewayv2_integration.nodejs_app.id}"
}

// Defines a log group to store access logs for the aws_apigatewayv2_stage.lambda API Gateway stage
resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"

  retention_in_days = 30
}

// Gives API Gateway permission to invoke your Lambda function.
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.nodejs_app.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}

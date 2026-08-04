# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "lambda_bucket_name" {
  description = "Created S3 bucket with the following name:"

  value = aws_s3_bucket.lambda_bucket.id
}

output "function_name" {
  description = "Created lambda function with the following name:"

  value = aws_lambda_function.nodejs_app.function_name
}

output "base_url" {
  description = "API Gateway URL to load the Node.js application (postfix with /index):"

  value = aws_apigatewayv2_stage.lambda.invoke_url
}

# Node.js application deployed using Terraform, S3, Lambda, and API Gateway

Deploys a basic Node.js application using Terraform, S3, Lambda, and API Gateway.

For more complex applications, for example using Express, it is likely more suitable to create a Lambda function using a container image, which could be stored in ECR.

## Set-up and deployment

Clone the repository.

Authenticate to AWS:
```
aws configure
```

Terraform is used to create the S3 bucket, Lambda function, API gateway, and CloudWatch logs. A ZIP of the Node.js application code is created and uploaded to the S3 bucket, from where it is synchronised with the Lambda function.

Run the following Terraform commands:
```
terraform init
terraform plan
terraform apply
```

The output will provide the public URL. Append /index to load the application, for example:
```
https://j9niey8xh4.execute-api.us-east-1.amazonaws.com/nodejs_app/index
```

Destroy all resources:
```
terraform destroy
```

## Updating the applcation

Simply update the files in /nodejs-app and run:
```
terraform apply
```

## Manual set-up and deployment

The set-up could be done manually, excluding the S3 storage by uploading the application ZIP directly to the Lambda function.

ZIP the code:
```
zip -r nodejs-app.zip ./nodejs-app
```

Create a Lambda function:

1. Go to AWS Lambda console.

2. Create the Lambda function:

    - Manually via the AWS Lambda console:
        - Runtime: Node.js 22.x
        - Handler: index.handler.
        - Execution Role: Create a role or select one with basic Lambda permissions.
        - Upload nodejs-app.zip in the console.

    - Using the AWS CLI:

        - aws lambda create-function \
            --function-name nodejs-app \
            --zip-file fileb://nodejs-app.zip \
            --handler index.handler \
            --runtime nodejs22.x \
            --role arn:aws:iam::<your-account-id>:role/<lambda-role>

4. Set a trigger using API Gateway from the Lambda function settings page:

    Add an HTTP API Gateway.

    Use default settings (public access).

    This will provide a public URL, for example:
    https://j9niey8xh4.execute-api.us-east-1.amazonaws.com/nodejs_app/index

5. Test it in a browser:
    ```
    https://your-api-url.amazonaws.com/default/nodejs-app/index
    ```

6. Remember to manually destroy the above AWS services to avoid unncessary charges!

## Sources

https://developer.hashicorp.com/terraform/tutorials/aws/lambda-api-gateway

https://github.com/hashicorp-education/learn-terraform-lambda-api-gateway
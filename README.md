# Node.js application deployed using Terraform, S3, Lambda, and API Gateway

Deploys a basic Node.js API using Terraform, S3, Lambda, and API Gateway.

For more complex applications, for example using Express, it is likely more suitable to create a Lambda function using a container image, which could be stored in ECR.

## Set-up and deployment

Clone the repository.

Authenticate to AWS:
```
aws configure
```

Terraform is used to create the S3 bucket, Lambda function, API gateway, and CloudWatch logs. A ZIP of the Node.js API code is created and uploaded to the S3 bucket, from where it is synchronised with the Lambda function.

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

Create the infrastructure using the AWS management console or CLI and upload the Node.JS API ZIP directly to the Lambda function. This avoids the need for an S3 bucket.

ZIP the code:
```
zip -r nodejs-app.zip ./nodejs-app
```

Create a Lambda function:

1. Go to AWS Lambda console.

2. Create the Lambda function:

    - Manually via the AWS Lambda console:
        - name: nodejs_app
        - Runtime: Node.js 24.x
        - Handler: index.handler (this is the default)
        - Execution Role: Create a role or select one with basic Lambda permissions.
        - Upload nodejs-app.zip in the console.

    - By default, Lambda creates an execution role with minimal permissions when you create a function in the Lambda console.
    If using the CLI, you will need to create the execution role first:
        ```
        aws iam create-role \
            --role-name lambda-ex \
            --assume-role-policy-document '{"Version": "2012-10-17","Statement": [{ "Effect": "Allow", "Principal": {"Service": "lambda.amazonaws.com"}, "Action": "sts:AssumeRole"}]}'
        ```

    - Using the AWS CLI:
        ```
        aws lambda create-function \
            --function-name nodejs-app \
            --zip-file fileb://nodejs-app.zip \
            --handler index.handler \
            --runtime nodejs22.x \
            --role arn:aws:iam::<your-account-id>:role/<lambda-role>
        ```

4. Create a trigger using API Gateway from the Lambda function settings page:

    Select "Add trigger" from the Lambda console.

    Select "API Gateway" as source and "Create new API", then "HTTP API".

    The pubic endpoint URL will be displayed in the "Triggers" section.

    This will provide a public URL, for example:
    https://r6mtzo95ji.execute-api.us-east-1.amazonaws.com/default/nodejs_app

5. Test it in a browser:
    ```
    https://your-api-url.amazonaws.com/default/nodejs-app/index
    ```

6. Remember to manually destroy the above AWS services to avoid unncessary charges.

## Sources

https://developer.hashicorp.com/terraform/tutorials/aws/lambda-api-gateway

https://github.com/hashicorp-education/learn-terraform-lambda-api-gateway
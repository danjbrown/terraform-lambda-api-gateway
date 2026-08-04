# A Node.js application deployed using Terraform, S3, and API Gateway

## Set-up

Clone the repository.

Authenticate to AWS:
```
aws configure
```

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

## Sources

https://developer.hashicorp.com/terraform/tutorials/aws/lambda-api-gateway

https://github.com/hashicorp-education/learn-terraform-lambda-api-gateway
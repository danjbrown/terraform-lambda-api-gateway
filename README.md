# A Node.js application deployed using Terraform, S3, and API Gateway

Clone the repository.

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
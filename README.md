# Webserver implementations in AWS with Terraform
## Currently included:
- EC2 + AMI with webserver installed 
- EC2 + Ansible
- S3 static hosting
- EKS + plain Kubernetes
- EKS + Helm
- ECS with Fargate
- Lambda function
- AppRunner
## Connectibility check:
- Local HTTP call
- Lambda function
### Planned features:
- Api Gateways for ECS
- Health Checks
- LoadBalancer should not exist if replica count is 1
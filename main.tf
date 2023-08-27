terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    time = {
      source = "hashicorp/time"
    }
    http = {
      source = "hashicorp/http"
    }
  }
}

provider "aws" {
  region = var.region
}

###########################################################
# EC2 host. Use with pre-installed webserver AMI or Ansible
###########################################################
# module "ec2_internet" {
#   source = "./modules/ec2_internet"
#   replicas          = var.replicas
#   ami               = var.ami
#   ec2_instance_type = var.ec2_instance_type
#   public_key        = var.public_key
#   resource_tags     = var.resource_tags
#   log_collection    = true
# }
# output "loadbalancer_ip" {
#   value = module.ec2_internet.loadbalancer_ip
# }
# output "ec2_connect_command" {
#   value = [
#     for ip in module.ec2_internet.ec2_public_ip : "ssh ${var.ami_user}@${ip}"
#   ]
# }

###########################################################
# Install Apache2 webserver on EC2 with Ansible
###########################################################
# resource "time_sleep" "wait_for_ec2" {
#   create_duration = "60s"
#   depends_on      = [module.ec2_internet]
# }
# module "ansible" {
#   source = "./modules/ansible"
#   urls         = module.ec2_internet.ec2_public_ip
#   ansible_user = var.ami_user
#   depends_on = [time_sleep.wait_for_ec2]
# }

###########################################################
# Lambda serverless host
###########################################################
# module "lambda_website" {
#   source = "./modules/lambda_website"
#   text   = "Welcome to my blog. My name is: "
# }
# output "website_url" {
#   value = module.lambda_website.url
# }

###########################################################
# S3 static host
###########################################################
# module "s3_static" {
#   source = "./modules/s3_static"
# }
# output "website_url" {
#   value = module.s3_static.url
# }

###########################################################
# EKS cluster
###########################################################
# module "eks" {
#   source = "./modules/eks"
#   kubernetes_version = "1.27"
# }

###########################################################
# NGINX on EKS with Helm
###########################################################
# provider "helm" {
#   kubernetes {
#     config_path = "~/.kube/config"
#   }
# }
# module "helm_website" {
#   source = "./modules/helm_website"
#   namespace = "nginx"
#   depends_on = [module.eks]
# }
# output "website_url" {
#   value = module.helm_website.website_url
# }

###########################################################
# NGINX on EKS with plain Kubernetes
###########################################################
# provider "kubernetes" {
#   config_path    = "~/.kube/config"
# }
# module "kubernetes_website" {
#   source = "./modules/kubernetes_website"
#   namespace = "webserver"
#   depends_on = [module.eks]
# }
# output "website_url" {
#   value = module.kubernetes_website.kubernetes_url
# }

###########################################################
# HealthCheck with Lambda
###########################################################
# resource "time_sleep" "wait_for_service" {
#   create_duration = "6s"
#   depends_on      = [module.s3_static]
# }
# module "lambda_scraper" {
#   source     = "./modules/lambda_scraper"
#   url        = module.s3_static.url
#   depends_on = [time_sleep.wait_for_service]
# }
# output "website_status_code" {
#   value = module.lambda_scraper.status_code
# }

###########################################################
# HealthCheck with local HTTP call for each instance
###########################################################
# resource "time_sleep" "wait_for_service" {
#   create_duration = "6s"
#   depends_on      = [module.s3_static]
# }
# data "http" "get_request" {
#   count = var.replicas
#   depends_on = [time_sleep.wait_for_ec2] 
#   url             = format("http://%s", module.ec2_internet.ec2_public_ip[count.index])
#   request_headers = {
#     Accept = "application/json"
#   }
#   lifecycle {
#     postcondition {
#       condition     = contains([200, 403], self.status_code)
#       error_message = "Webservice unreachable"
#     }
#   }
# }
# output "http_status_codes" {
#   value = data.http.get_request[*].status_code
# }
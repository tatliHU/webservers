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

module "ec2_internet" {
  source = "./modules/ec2_internet"
  
  replicas          = var.replicas
  ami               = var.ami
  ec2_instance_type = var.ec2_instance_type
  public_key        = var.public_key
  resource_tags     = var.resource_tags
}

# module "ansible" {
#   source = "./modules/ansible"

#   urls         = module.ec2_internet.ec2_public_ip
#   ansible_user = var.ami_user
#   depends_on = [time_sleep.wait_for_ec2]
# }

resource "time_sleep" "wait_for_ec2" {
  create_duration = "60s"
  depends_on      = [module.ec2_internet]
}

/*
module "lambda_scraper" {
  source     = "./modules/lambda_scraper"
  url        = formatlist("http://%s", module.ec2_internet.ec2_public_ip)
  depends_on = [time_sleep.wait_for_ec2]
}


data "http" "get_request" {
  count = var.replicas
  depends_on = [time_sleep.wait_for_ec2]
  
  url             = format("http://%s", module.ec2_internet.ec2_public_ip[count.index])
  request_headers = {
    Accept = "application/json"
  }
  lifecycle {
    postcondition {
      condition     = contains([200, 403], self.status_code)
      error_message = "Webservice unreachable"
    }
  }
}
*/
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

locals {
    ecr_type = var.ECR_visibility == "public" ? "ECR_PUBLIC" : "ECR"
}

resource "aws_apprunner_service" "webserver" {
  service_name = var.service_name

  source_configuration {
    image_repository {
      image_configuration {
        port = var.port
      }
      image_identifier      = var.image
      image_repository_type = local.ecr_type
    }
    auto_deployments_enabled = false
  }

  tags = var.resource_tags
}
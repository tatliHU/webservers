variable "region" {
  description = "AWS region for the project"
  type        = string
  default     = "us-east-2"
}

variable "replicas" {
  description = "Number of webservers"
  type        = number
  default     = 1
}

variable "resource_tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default     = {
    Name        = "ec2-internet",
    managed_by  = "terraform"
  }
}

variable "ec2_instance_type" {
  description = "AWS EC2 instance type."
  type        = string
  default     = "t2.micro"
}

variable "public_key" {
  description = "Public key for ssh as a .pub file content"
  type        = string
  sensitive   = true
}

variable "ami_user"{
  description = "User for AMI login"
  type        = string
  default     = "ec2-user"
}

variable "ami"{
  description = "AMI for EC2"
  type        = string
  default     = "ami-08c50cb06459e56a4"
}


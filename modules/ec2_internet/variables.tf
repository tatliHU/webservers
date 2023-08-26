variable "resource_tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default     = {
    Name        = "ec2-internet",
    project     = "terraform-app",
    managed_by  = "terraform"
  }
}

variable "ec2_instance_type" {
  description = "AWS EC2 instance type."
  type        = string
  default     = "t2.micro"
  validation {
    condition     = contains(["t2.nano", "t2.micro"], var.ec2_instance_type)
    error_message = "Unknown or expensive EC2 type."
  }
}

variable "public_key" {
  description = "Public key for ssh as a .pub file content"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.public_key) > 0 && length(regexall("[^a-zA-Z0-9-+ @./]", var.public_key)) == 0
    error_message = "Public key is empty string or contains invalid characters."
  }
}

variable "ami" {
  description = "AMI for EC2 instance"
  type        = string
}

variable "replicas" {
  description = "Number of webserver instances"
  type        = number
  default     = 1
  validation {
    condition     = 0 < var.replicas && var.replicas < 3
    error_message = "Number of replicas shuld be between 1 and 3."
  }
}

variable "log_collection" {
  description = "Enable LoadBalancer access log collection to S3."
  type        = bool
  default     = false
}
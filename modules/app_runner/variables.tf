variable "resource_tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default     = {
    Name        = "app_runner_nginx",
    project     = "terraform-app",
    managed_by  = "terraform"
  }
}

variable "service_name" {
  description = "Name of your App Runner service"
  type        = string
  default     = "webserver"
}

variable "ECR_visibility" {
  description = "Decides if ECR is private or public"
  type        = string
  default     = "private"
  validation {
    condition     = contains(["private", "public"], var.ECR_visibility)
    error_message = "ECR visibility can only be public or private."
  }
}

variable "image" {
  description = "Container image to use"
  type        = string
  default     = "public.ecr.aws/nginx/nginx:latest"
}

variable "port" {
  description = "Port to accept traffic"
  type        = number
  default     = 80
  validation {
    condition     = 0 < var.port && var.port < 65535
    error_message = "Please provide a valid port number."
  }
}
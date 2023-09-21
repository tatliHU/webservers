variable "resource_tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default     = {
    Name        = "ecs_nginx",
    project     = "terraform-app",
    managed_by  = "terraform"
  }
}

variable "service_name" {
  description = "Name of your App Runner service"
  type        = string
  default     = "webserver"
}

variable "image" {
  description = "Container image to use"
  type        = string
  default     = "public.ecr.aws/nginx/nginx:latest"
}

variable "replicas" {
  description = "Number of webserver containers to run"
  type        = number
  default     = 1
}
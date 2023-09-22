variable "resource_tags" {
  description = "Tags to set for all resources"
  type        = map(string)
}

variable "log_collection" {
  description = "Enable LoadBalancer access log collection to S3."
  type        = bool
}

variable "security_group_id" {
  description = "Security group used by the ALB"
  type        = string
}

variable "vpc_id" {
  description = "VPC used by the ALB"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets used by the ALB"
  type        = list(string)
}

variable "ec2_ids" {
  description = "EC2s targeted by the ALB"
  type        = list(string)
}
variable "resource_tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default     = {
    Name        = "eks_nginx",
    project     = "terraform-app",
    managed_by  = "terraform"
  }
}

variable "cluster_name" {
  description = "Name of your EKS cluster"
  type        = string
  default     = "nginx"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.27"
}
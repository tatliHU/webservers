variable "url" {
  description = "URL to scrape"
  type        = string
  default     = "https://www.telex.hu"
}

variable "resource_tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default     = {
    Name        = "eks_nginx",
    project     = "terraform-app",
    managed_by  = "terraform"
  }
}

variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "scraper"
}
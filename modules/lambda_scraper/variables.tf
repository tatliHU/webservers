variable "url" {
  description = "URLs to scrape"
  type        = list(string)
  default     = ["https://www.google.com", "https://www.facebook.com"]
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
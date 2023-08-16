variable "root_dir" {
  description = "Path to resource files (html, css, png, etc) for the website. Leave empty to use default resources."
  type        = string
  default     = ""
}

variable "resource_tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default     = {
    Name        = "s3_static",
    project     = "terraform-app",
    managed_by  = "terraform"
  }
}
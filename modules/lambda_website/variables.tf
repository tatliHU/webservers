variable "text" {
  description = "Server greets visitors with this text"
  type        = string
  default     = "Ahoy! I am the Lorax and I speak for the trees. The trees say: "
}

variable "resource_tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default     = {
    Name        = "lambda_website",
    project     = "terraform-app",
    managed_by  = "terraform"
  }
}

variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "server"
}
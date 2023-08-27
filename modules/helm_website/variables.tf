variable "namespace" {
  description = "Namespace for webserver."
  type        = string
  default     = "helm_webserver"
}

variable "create_namespace" {
  description = "Create a new namespace or use an existing one."
  type        = bool
  default     = true
}
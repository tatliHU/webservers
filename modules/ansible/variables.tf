variable "urls" {
  description = "IPs for hosts managed by Ansible"
  type        = list
}

variable "ansible_user" {
  description = "User that Ansible use for login"
  type        = string
  default     = "ec2-user"
}
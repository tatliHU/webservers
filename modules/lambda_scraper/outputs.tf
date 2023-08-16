output "status_code" {
  value = jsondecode(aws_lambda_invocation.start.result)
}

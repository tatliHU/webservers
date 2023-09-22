output "ssh_ips" {
  value = aws_instance.internet_ec2[*].public_ip
}

output "service_url" {
  value = var.replicas > 1 ? format("http://%s", module.alb[0].loadbalancer_ip) : format("http://%s", aws_instance.internet_ec2[0].public_ip)
}

output "loadbalancer_ip" {
  value = aws_lb.internet_load_balancer.dns_name
}
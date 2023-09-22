output "loadbalancer_ip" {
    value = aws_lb.ecs.dns_name
}
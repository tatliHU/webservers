output "ec2_public_ip" {
  value = aws_instance.internet_ec2[*].public_ip
  //value = formatlist("http://%s", aws_instance.internet_ec2[*].public_ip)
}

output "loadbalancer_ip" {
  value = aws_lb.internet_load_balancer.dns_name
}

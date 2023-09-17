resource "time_sleep" "wait_for_service" {
  create_duration = "30s"
  depends_on      = [aws_ecs_service.nginx]
}

data "aws_network_interface" "interface_tags" {
  depends_on = [time_sleep.wait_for_service]
  filter {
    name   = "tag:aws:ecs:serviceName"
    values = [var.service_name]
  }
}

output "network_interface" {
    value = data.aws_network_interface.interface_tags.association[0].public_ip
}
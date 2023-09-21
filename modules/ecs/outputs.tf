resource "time_sleep" "wait_for_service" {
  create_duration = "30s"
  depends_on      = [aws_ecs_service.nginx]
}

data "aws_network_interfaces" "interface_tags" {
  depends_on = [time_sleep.wait_for_service]
  filter {
    name   = "tag:aws:ecs:serviceName"
    values = [var.service_name]
  }
}

data "aws_network_interface" "interface_by_id" {
  count = var.replicas
  id    = data.aws_network_interfaces.interface_tags.ids[count.index]
}

output "network_interfaces" {
    value = data.aws_network_interface.interface_by_id[*].association[0].public_ip
}
data "kubernetes_service" "nginx" {
  metadata {
    name      = "nginx"
    namespace = "nginx"
  }
}

output "public_ip" {
  value = data.kubernetes_service.nginx.status[0].load_balancer[0].ingress[0].hostname
}
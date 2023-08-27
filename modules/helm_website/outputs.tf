data "kubernetes_service" "nginx" {
  metadata {
    name      = "nginx"
    namespace = var.namespace
  }
}

output "website_url" {
  value = data.kubernetes_service.nginx.status[0].load_balancer[0].ingress[0].hostname
}

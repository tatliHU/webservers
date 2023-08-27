data "kubernetes_service" "webserver" {
  metadata {
    name      = "nginx"
    namespace = var.namespace
  }
  depends_on = [module.kubernetes_webserver]
}
output "kubernetes_url" {
  value = data.kubernetes_service.webserver.status[0].load_balancer[0].ingress[0].hostname
}
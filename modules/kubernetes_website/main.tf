terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

resource "kubernetes_namespace" "webserver" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_deployment" "webserver" {
  metadata {
    name = "webserver"
    namespace = var.namespace
    labels = {
      app        = "nginx"
      managed_by = "Terraform"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "nginx"
      }
    }
    template {
      metadata {
        labels = {
          app        = "nginx"
          managed_by = "Terraform"
        }
      }
      spec {
        container {
          image = "nginx:latest"
          name  = "nginx"
          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 30
            period_seconds        = 30
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "webserver" {
  metadata {
    name      = "nginx"
    namespace = var.namespace
  }
  spec {
    selector = {
      app = "nginx"
    }
    port {
      port        = 80
      target_port = 80
    }
    type = "LoadBalancer"
  }
}
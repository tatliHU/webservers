terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }
  }
}

resource "helm_release" "nginx" {
  name  = "nginx"
  chart = "oci://registry-1.docker.io/bitnamicharts/nginx"
  namespace        = var.namespace
  create_namespace = var.create_namespace
}
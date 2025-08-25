resource "kubernetes_namespace" "required" {
  provider = kubernetes.kind
  for_each = toset(var.k8s_namespaces)

  metadata {
    name = each.key
  }
}

# Manifests need access to the cluster on planning.
resource "kubernetes_manifest" "ingress_monitoring" {
  provider = kubernetes.kind

  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata = {
      name      = var.k8s_ingress_name_monitoring
      namespace = var.helm_kube_prometheus_stack_namespace
      annotations = {
        "nginx.ingress.kubernetes.io/rewrite-target" = "/$2"
      }
    }
    spec = {
      rules = [{
        http = {
          paths = [{
            path = "/${var.helm_kube_prometheus_stack_namespace}/grafana(/|$)(.*)"
            pathType = "ImplementationSpecific"
            backend = {
              service = {
                name = "${helm_release.kube_prometheus_stack.name}-grafana"
                port = { number = 80 }
              }
            }
          },
          {
            path = "/${var.helm_kube_prometheus_stack_namespace}/alertmanager(/|$)(.*)"
            pathType = "ImplementationSpecific"
            backend = {
              service = {
                name = "${helm_release.kube_prometheus_stack.name}-alertmanager"
                port = { number = 9093 }
              }
            }
          }]
        }
      }]
    }
  }

  depends_on = [
    null_resource.wait_for_kube_prometheus_stack
  ]
}

# Separate ingress since prometheus doesn't accept path rewrites.
resource "kubernetes_manifest" "ingress_prometheus" {
  provider = kubernetes.kind

  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata = {
      name      = "prometheus-ingress"
      namespace = var.helm_kube_prometheus_stack_namespace
    }
    spec = {
      rules = [{
        http = {
          paths = [{
            path = "/${var.helm_kube_prometheus_stack_namespace}/prometheus"
            pathType = "Prefix"
            backend = {
              service = {
                name = "${helm_release.kube_prometheus_stack.name}-prometheus"
                port = { number = 9090 }
              }
            }
          }]
        }
      }]
    }
  }
  
  depends_on = [
    null_resource.wait_for_kube_prometheus_stack
  ]
}
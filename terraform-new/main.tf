# Docker

resource "docker_image" "registry" {
  name = var.registry_image
}

resource "docker_volume" "registry_data" {
  name = "${var.project_prefix}-${var.registry_volume_suffix}"
}

resource "docker_container" "registry" {
  name    = "${var.project_prefix}-${var.registry_container_suffix}"
  image   = docker_image.registry.image_id
  restart = "always"

  ports {
    internal = var.registry_internal_port
    external = var.registry_external_port
  }

  volumes {
    volume_name    = docker_volume.registry_data.name
    container_path = var.registry_volume_container_path
  }
}

# Minikube

resource "minikube_cluster" "primary" {
  driver       = "docker"
  cluster_name = "${var.project_prefix}-${var.minikube_suffix}"
  addons = [
    "ingress",
    "dashboard"
  ]
}

resource "null_resource" "wait_for_ingress_nginx" {
  triggers = {
    key = uuid()
  }

  provisioner "local-exec" {
    command = <<EOF
      set -e
      NAMESPACE=ingress-nginx
      CONTROLLER_SELECTOR="app.kubernetes.io/component=controller"
      WEBHOOK_NAME="ingress-nginx-admission"

      echo "Waiting for NGINX ingress controller pod to be ready..."
      kubectl wait --namespace $NAMESPACE \
        --for=condition=ready pod \
        --selector=$CONTROLLER_SELECTOR \
        --timeout=180s

      echo "Polling for admission webhook readiness..."
      for i in $(seq 1 60); do
        STATUS=$(kubectl get validatingwebhookconfiguration $WEBHOOK_NAME -o jsonpath='{.webhooks[0].clientConfig.service.name}' || echo "notready")
        if [ "$STATUS" != "notready" ]; then
          echo "Admission webhook is ready!"
          exit 0
        fi
        echo "Webhook not ready yet, retrying in 2s..."
        sleep 2
      done

      echo "Timeout waiting for admission webhook."
      exit 1
    EOF
  }

  depends_on = [minikube_cluster.primary]
}

resource "null_resource" "wait_for_kube_prometheus_stack" {
  triggers = { 
    key = uuid()
  }

  provisioner "local-exec" {
    command = <<EOF
      printf "\nWaiting for the monitoring...\n"
      kubectl wait --namespace ${var.helm_kube_prometheus_stack_namespace} \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/name=grafana \
        --timeout=180s
    EOF
  }

  depends_on = [minikube_cluster.primary]
}

data "external" "minikube_ip" {
  program = ["bash", "-c", <<EOT
IP=$(minikube -p ${minikube_cluster.primary.cluster_name} ip)
echo "{\"ip\": \"$IP\"}"
EOT
  ]
  depends_on = [
    minikube_cluster.primary
  ]
}

locals {
  minikube_ip = data.external.minikube_ip.result["ip"]
}

# Helm

resource "helm_release" "kube_prometheus_stack" {
  name             = var.helm_kube_prometheus_stack_name
  repository       = var.helm_kube_prometheus_stack_repo
  chart            = "kube-prometheus-stack"
  version          = var.helm_kube_prometheus_stack_version
  namespace        = var.helm_kube_prometheus_stack_namespace
  create_namespace = true

  values = [<<EOF
grafana:
  adminUser: admin
  adminPassword: "1234"
EOF
  ]

  depends_on = [null_resource.wait_for_ingress_nginx]
}

# Kubernetes

resource "kubernetes_ingress_v1" "dashboard" {
  metadata {
    name      = var.k8s_ingress_kubernetes_dashboard
    namespace = var.k8s_namespace_kube_dashboard
  }

  spec {
    rule {
      host = "dashboard.${local.minikube_ip}.nip.io"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "kubernetes-dashboard"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    null_resource.wait_for_ingress_nginx
  ]
}

resource "kubernetes_ingress_v1" "monitoring" {
  metadata {
    name      = var.k8s_ingress_monitoring
    namespace = var.k8s_namespace_monitoring
  }

  spec {
    rule {
      host = "prometheus.${local.minikube_ip}.nip.io"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "${var.helm_kube_prometheus_stack_name}-prometheus"
              port {
                number = 9090
              }
            }
          }
        }
      }
    }
    rule {
      host = "grafana.${local.minikube_ip}.nip.io"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "${var.helm_kube_prometheus_stack_name}-grafana"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
    rule {
      host = "altertmanager.${local.minikube_ip}.nip.io"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "${var.helm_kube_prometheus_stack_name}-alertmanager"
              port {
                number = 9093
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    null_resource.wait_for_ingress_nginx
  ]
}

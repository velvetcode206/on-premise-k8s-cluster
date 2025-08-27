# Docker

resource "docker_network" "ci_network" {
  name   = "${var.project_prefix}-ci-network"
  driver = "bridge"
}

# Registry

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

  depends_on = [ 
    docker_image.registry,
    docker_volume.registry_data
  ]
}

# Jenkins

resource "docker_image" "jenkins" {
  name         = "${var.project_prefix}-jenkins:latest"

  build {
    context    = "${path.module}/../jenkins"
    dockerfile = "${path.module}/../jenkins/Dockerfile"
  }
}

resource "docker_volume" "jenkins_home" {
  name = "${var.project_prefix}-jenkins-home"
}

resource "docker_container" "jenkins" {
  name  = "${var.project_prefix}-jenkins"
  image = docker_image.jenkins.image_id
  restart = "always"

  ports {
    internal = var.jenkins_internal_port
    external = var.jenkins_external_port
  }

  ports {
    internal = var.jenkins_agent_internal_port
    external = var.jenkins_agent_external_port
  }

  volumes {
    volume_name    = docker_volume.jenkins_home.name
    container_path = "/var/jenkins_home"
  }

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }

  env = [
    "JENKINS_OPTS=--httpPort=8080"
  ]

  networks_advanced {
    name = docker_network.ci_network.name
  }

  depends_on = [ 
    docker_network.ci_network,
    docker_image.jenkins,
    docker_volume.jenkins_home
  ]
}

resource "docker_image" "sonarqube" {
  name = "sonarqube:lts"
}

resource "docker_container" "sonarqube" {
  name  = "${var.project_prefix}-sonarqube"
  image = docker_image.sonarqube.image_id
  restart = "always"

  ports {
    internal = var.sonarqube_internal_port
    external = var.sonarqube_external_port
  }

  env = [
    "SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true"
  ]

  networks_advanced {
    name = docker_network.ci_network.name
  }

  depends_on = [
    docker_network.ci_network,
    docker_image.sonarqube
  ]
}

# Minikube

resource "minikube_cluster" "primary" {
  driver       = "docker"
  cluster_name = "${var.project_prefix}-${var.minikube_suffix}"
  addons = [
    "ingress",
    "dashboard"
  ]
  insecure_registry = [
    "localhost:5000"
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

  depends_on = [
    null_resource.wait_for_ingress_nginx
  ]
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

  depends_on = [helm_release.kube_prometheus_stack]
}

# Kubernetes

resource "kubernetes_namespace" "des" {
  metadata {
    name = "des"
    labels = {
      environment = "dev"
    }
  }
}

resource "kubernetes_namespace" "prd" {
  metadata {
    name = "prd"
    labels = {
      environment = "prd"
    }
  }
}

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
    null_resource.wait_for_kube_prometheus_stack,
    null_resource.wait_for_ingress_nginx
  ]
}

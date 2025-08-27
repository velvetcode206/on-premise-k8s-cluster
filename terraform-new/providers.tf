terraform {
  required_version = "~> 1.13.0"

  required_providers {
    external = {
      source = "hashicorp/external"
      version = "2.3.5"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.4"
    }

    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.6.2"
    }

    minikube = {
      source = "scott-the-programmer/minikube"
      version = "~> 0.5.3"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0.2"
    }
  }
}

provider "external" {}

provider "null" {}

provider "docker" {}

provider "minikube" {}

provider "kubernetes" {
  host                   = minikube_cluster.primary.host
  client_certificate     = minikube_cluster.primary.client_certificate
  client_key             = minikube_cluster.primary.client_key
  cluster_ca_certificate = minikube_cluster.primary.cluster_ca_certificate
}

provider "helm" {
  kubernetes = {
    host                   = minikube_cluster.primary.host
    client_certificate     = minikube_cluster.primary.client_certificate
    client_key             = minikube_cluster.primary.client_key
    cluster_ca_certificate = minikube_cluster.primary.cluster_ca_certificate
  }
}
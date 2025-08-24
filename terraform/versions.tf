terraform {
  required_version = "~> 1.13.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.6.2"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0.2"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38.0"
    }

    kind = {
      source  = "tehcyx/kind"
      version = "~> 0.9.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.4"
    }
  }
}

provider "docker" {}

provider "helm" {
  kubernetes = {
    host                   = kind_cluster.local.endpoint
    cluster_ca_certificate = kind_cluster.local.cluster_ca_certificate
    client_certificate     = kind_cluster.local.client_certificate
    client_key             = kind_cluster.local.client_key
  }
}

provider "kubernetes" {
  host                   = kind_cluster.local.endpoint
  cluster_ca_certificate = kind_cluster.local.cluster_ca_certificate
  client_certificate     = kind_cluster.local.client_certificate
  client_key             = kind_cluster.local.client_key
}

provider "kind" {}
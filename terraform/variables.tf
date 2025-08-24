# Project

variable "project_prefix" {
  description = "Prefix to be used in the created resources."
  type        = string
  default     = "on-premises-k8s"
}

# Container Registry

variable "local_registry_volume_name_suffix" {
  description = "The suffix of the local registry volume name."
  type        = string
  default     = "registry-data"
}

variable "local_registry_volume_path_data" {
  description = "The path inside the container where images are saved."
  type        = string
  default     = "/var/lib/registry"
}

variable "local_registry_name_suffix" {
  description = "The suffix of the local registry name."
  type        = string
  default     = "registry"
}

variable "local_registry_image" {
  description = "Image to be used in the local container registry."
  type        = string
  default     = "registry:2"
}

variable "local_registry_internal_port" {
  description = "Port available in the local container registry."
  type        = number
  default     = 5000
}

variable "local_registry_external_port" {
  description = "Port exposed in the host to access the local container registry."
  type        = number
  default     = 5000
}

# Kind Cluster

variable "kind_cluster_name_suffix" {
  description = "The suffix of the kind cluster name."
  type        = string
  default     = "cluster"
}

variable "kind_cluster_config_path" {
  type        = string
  description = "The location where this cluster's kubeconfig will be saved to."
  default     = "~/.kube/config"
}

variable "kind_cluster_network_name" {
  type        = string
  description = "The network name that should be create by kind."
  default     = "kind"
}

# Helm

variable "helm_ingress_nginx_name_suffix" {
  type        = string
  description = "The suffix of the helm's ingress-nginx release name."
  default     = "ingress-nginx"
}

variable "helm_ingress_nginx_repo" {
  type        = string
  description = "Url to fecth the ingress-nginx repository."
  default     = "https://kubernetes.github.io/ingress-nginx"
}

variable "helm_ingress_nginx_chart" {
  type        = string
  description = "Chart to be used from the ingress-nginx repository (needs to match the name in the repo)."
  default     = "ingress-nginx"
}

variable "helm_ingress_nginx_version" {
  type        = string
  description = "The version for the nginx ingress controller."
  default     = "4.7.1"
}

variable "helm_ingress_nginx_namespace" {
  type        = string
  description = "The ingress-nginx namespace (it will be created if needed)."
  default     = "ingress-nginx"
}

variable "helm_ingress_nginx_kind_patch_file" {
  type        = string
  description = "A file with values to patch the ingress nginx usage with Kind."
  default     = "ingress-nginx-kind-patch.yaml"
}

# Kubernetes

variable "k8s_namespaces" {
  default = ["des", "prd"]
}
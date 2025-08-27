# Project Settings

variable "project_prefix" {
  description = "Prefix for created resources."
  type        = string
  default     = "on-prem-k8s"
}

# Local Container Registry

variable "registry_image" {
  description = "Local registry container image."
  type        = string
  default     = "registry:3.0.0"
}

variable "registry_volume_suffix" {
  description = "Suffix for local registry volume name."
  type        = string
  default     = "registry-data"
}

variable "registry_container_suffix" {
  description = "Suffix for local registry container name."
  type        = string
  default     = "registry"
}

variable "registry_internal_port" {
  description = "Internal port for local registry container."
  type        = number
  default     = 5000
}

variable "registry_external_port" {
  description = "Port on the host to access the local registry."
  type        = number
  default     = 5000
}

variable "registry_volume_container_path" {
  description = "Path inside the container where images are stored."
  type        = string
  default     = "/var/lib/registry"
}

# Minikube

variable "minikube_suffix" {
  description = "Suffix for the primary minikube cluster."
  type        = string
  default     = "primary"
}

variable "dashboard_node_port" {
  description = "NodePort to expose the Kubernetes Dashboard"
  type        = number
  default     = 30000
}

# Helm

variable "helm_ingress_nginx_name" {
  type        = string
  description = "The ingress_nginx helm release name."
  default     = "ingress-nginx"
}

variable "helm_kubernetes_dashboard_name" {
  type        = string
  description = "The kubernetes-dashboard helm release name."
  default     = "kubernetes-dashboard"
}

variable "helm_ingress_nginx_version" {
  type        = string
  description = "The version for the ingress-nginx chart."
  default     = "4.13.1"
}

variable "helm_kubernetes_dashboard_version" {
  type        = string
  description = "The version for the kubernetes-dashboard chart."
  default     = "7.13.0"
}

# k8s

variable "k8s_namespace_ingress_nginx" {
  type        = string
  description = "The ingress-nginx namespace."
  default     = "ingress-nginx"
}

variable "k8s_namespace_kube_dashboard" {
  type        = string
  description = "The kube-dashboard namespace."
  default     = "kubernetes-dashboard"
}

variable "k8s_ingress_kubernetes_dashboard" {
  description = "The array of custom namespaces that will be created."
  type        = string
  default     = "kubernetes-dashboard"
}
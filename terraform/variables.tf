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

# Helm nginx

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

variable "helm_ingress_nginx_version" {
  type        = string
  description = "The version for the ingress-nginx controller."
  default     = "4.7.1"
}

variable "helm_ingress_nginx_namespace" {
  type        = string
  description = "The ingress-nginx namespace (it will be created if needed)."
  default     = "ingress-nginx"
}

variable "helm_ingress_nginx_values_file" {
  type        = string
  description = "A file with values to patch the ingress nginx usage with Kind."
  default     = "helm-ingress-nginx-values.yaml"
}

# Helm Prometheus

variable "helm_kube_prometheus_stack_name_suffix" {
  type        = string
  description = "The suffix of the kube-prometheus-stack helm release name."
  default     = "prometheus"
}

variable "helm_kube_prometheus_stack_repo" {
  type        = string
  description = "Url to fecth the kube-prometheus-stack repository."
  default     = "https://prometheus-community.github.io/helm-charts"
}

variable "helm_kube_prometheus_stack_version" {
  type        = string
  description = "The version for the kube-prometheus-stack chart."
  default     = "77.0.0"
}

variable "helm_kube_prometheus_stack_namespace" {
  type        = string
  description = "The kube-prometheus-stack namespace (it will be created if needed)."
  default     = "monitoring"
}

variable "helm_kube_prometheus_stack_values_file" {
  type        = string
  description = "A file with values to patch the ingress nginx usage with Kind."
  default     = "helm-prometheus-stack-values.yaml"
}

# Kubernetes

variable "k8s_namespaces" {
  default = ["des", "prd"]
  description = "The array of custom namespaces that will be created."
}

variable "k8s_ingress_name_monitoring" {
  type        = string
  description = "Name of the ingress that defines Grafana and Alertmanager."
  default     = "ingress-monitoring"
}
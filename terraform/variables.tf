# Project Settings

variable "project_prefix" {
  type        = string
  default     = "on-prem-k8s"
}

variable "grafana_user" {
  type        = string
}

variable "grafana_password" {
  type        = string
}

variable "registry_user" {
  type        = string
}

variable "registry_password" {
  type        = string
}

# Registry

variable "registry_image" {
  type        = string
  default     = "registry:3.0.0"
}

variable "registry_volume_suffix" {
  type        = string
  default     = "registry-data"
}

variable "registry_container_suffix" {
  type        = string
  default     = "registry"
}

variable "registry_internal_port" {
  type        = number
  default     = 5000
}

variable "registry_external_port" {
  type        = number
  default     = 5000
}

variable "registry_volume_container_path" {
  type        = string
  default     = "/var/lib/registry"
}

# Jenkins

variable "jenkins_internal_port" {
  type        = number
  default     = 8080
}

variable "jenkins_external_port" {
  type        = number
  default     = 5001
}

variable "jenkins_agent_internal_port" {
  type        = number
  default     = 50000
}

variable "jenkins_agent_external_port" {
  type        = number
  default     = 50000
}

# Sonarqube

variable "sonarqube_internal_port" {
  type        = number
  default     = 9000
}

variable "sonarqube_external_port" {
  type        = number
  default     = 5002
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

variable "helm_kube_prometheus_stack_name" {
  type        = string
  description = "The kube-prometheus-stack helm release name."
  default     = "kube-prometheus-stack"
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

variable "k8s_namespace_monitoring" {
  type        = string
  description = "The monitoring namespace."
  default     = "monitoring"
}

variable "k8s_ingress_kubernetes_dashboard" {
  description = "The Kubernetes Dashboad ingress name."
  type        = string
  default     = "kubernetes-dashboard"
}

variable "k8s_ingress_monitoring" {
  description = "The monitoring ingress name."
  type        = string
  default     = "monitoring"
}

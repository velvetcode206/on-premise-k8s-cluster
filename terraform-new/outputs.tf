output "local_registry_url" {
  description = "The accessible address of the local registry"
  value       = "http://localhost:${var.registry_external_port}/v2/_catalog"
}

# output "dashboard_url" {
#   description = "URL to access the Kubernetes Dashboard"
#   value       = "${kubernetes_ingress_v1.dashboard.spec}"
# }

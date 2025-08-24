output "registry_url" {
  value = "localhost:${var.local_registry_external_port}/v2/_catalog"
  description = "URL to access the local registry"
}
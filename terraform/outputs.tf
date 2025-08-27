output "local_registry_url" {
  value = "http://localhost:${var.registry_external_port}/v2/_catalog"
}

output "jenkins_url" {
  value = "http://localhost:${var.jenkins_external_port}/"
}

output "sonarqube_url" {
  value = "http://localhost:${var.sonarqube_external_port}/"
}
data "docker_network" "kind" {
  name = var.kind_cluster_network_name
}

resource "docker_volume" "local_registry_data" {
  name = "${var.project_prefix}-${var.local_registry_volume_name_suffix}"
}

resource "docker_image" "local_registry" {
  name = var.local_registry_image
}

resource "docker_container" "local_registry" {
  name  = "${var.project_prefix}-${var.local_registry_name_suffix}"
  image = docker_image.local_registry.image_id

  ports {
    internal = var.local_registry_internal_port
    external = var.local_registry_external_port
  }

  volumes {
    volume_name = docker_volume.local_registry_data.name
    container_path = var.local_registry_volume_path_data
  }

  networks_advanced {
    name = data.docker_network.kind.name
  }
}
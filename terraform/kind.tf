resource "kind_cluster" "local" {
  name            = "${var.project_prefix}-${var.kind_cluster_name_suffix}"
  kubeconfig_path = pathexpand(var.kind_cluster_config_path)
  wait_for_ready  = true

  kind_config {
    kind                      = "Cluster"
    api_version               = "kind.x-k8s.io/v1alpha4"
    containerd_config_patches = [
      <<-TOML
            [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:5000"]
                endpoint = ["http://${docker_container.local_registry.name}:5000"]
            TOML
    ]

    node {
      role = "control-plane"
      kubeadm_config_patches = [
        <<EOF
kind: InitConfiguration
nodeRegistration:
  kubeletExtraArgs:
    node-labels: "ingress-ready=true"
EOF
      ]
    }

    node {
      role = "worker"
    }
    
    node {
      role = "worker"
      labels = {
        role: "app"
      }
    }

    node {
      role = "worker"
      labels = {
        role: "ingress"
      }

      extra_port_mappings {
        container_port = 80
        host_port      = 80
      }
      
      extra_port_mappings {
        container_port = 443
        host_port      = 443
      }
    }
  }
}
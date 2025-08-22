#!/bin/bash

set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPTS_DIR/../.env"

KIND_CONFIG_PATH="$SCRIPTS_DIR/../$KIND_CONFIG_PATH"
KIND_REQUIRED_PATH="$SCRIPTS_DIR/../$KIND_REQUIRED_PATH"
KIND_DES_PATH="$SCRIPTS_DIR/../$KIND_DES_PATH"
KIND_PRD_PATH="$SCRIPTS_DIR/../$KIND_PRD_PATH"

log() {
  local level message="$*"

  case "${1^^}" in
    SUCCESS|WARNING|ERROR)
      level="${1^^}"
      shift
      ;;
    *)
      level="INFO"
      ;;
  esac
  
  case "$level" in
    SUCCESS) color="\033[0;32m" ;;
    WARNING) color="\033[0;33m" ;;
    ERROR)   color="\033[0;31m" ;;
    INFO)    color="\033[0;34m" ;;
  esac
  printf "%b[%s][%s]%b %s\n" "$color" "$(date +'%H:%M:%S')" "$level" "\033[0m" "$message"
}

create_container_registry() {
  local is_running=$(docker inspect -f '{{.State.Running}}' "${REGISTRY_NAME}" 2>/dev/null || true)
  if [ "${is_running}" = "true" ]; then
    log WARNING "Container registry ${REGISTRY_NAME} already running at http://localhost:${REGISTRY_HOST_PORT}/v2/_catalog"
    return 0
  fi
  docker rm -f "${REGISTRY_NAME}" 2>/dev/null || true
  log "Starting container registry ${REGISTRY_NAME} at port ${REGISTRY_HOST_PORT}..."
  docker run -d --restart=always -p "${REGISTRY_HOST_PORT}:5000" --name "${REGISTRY_NAME}" "${REGISTRY_IMAGE}"
  log "Container registry initialized at http://localhost:${REGISTRY_HOST_PORT}/v2/_catalog"
}

create_kind_cluster() {
  if kind get clusters | grep -q "^${KIND_CLUSTER_NAME}$"; then
    log WARNING "Kind cluster ${KIND_CLUSTER_NAME} already exists."
    return 0
  fi
  log "Creating kind cluster ${KIND_CLUSTER_NAME}..."
  kind create cluster --name "$KIND_CLUSTER_NAME" --image "$KIND_NODE_IMAGE" --config "$KIND_CONFIG_PATH"
  log "Installing required manifests..."
  kubectl apply -f "${KIND_REQUIRED_PATH}"
  kubectl rollout status -n ingress-nginx deployment/ingress-nginx-controller --timeout=600s
}

connect_container_registry_to_kind_cluster_network() {
  if docker network inspect "$KIND_NETWORK" | grep -q "$REGISTRY_NAME"; then
    log WARNING "Registry already connected to cluster network"
    return 0
  fi
  log "Connecting registry to Kind network..."
  docker network connect "$KIND_NETWORK" "$REGISTRY_NAME" || true
}

create_infrastructure() {
  log "Creating infrastructure..."
  create_container_registry
  create_kind_cluster
  connect_container_registry_to_kind_cluster_network
  log SUCCESS "Infrastructure ready!"
  echo  
}

destroy_infrastructure() {
  log "Destroying infrastructure..."
  mapfile -t containers < <(docker ps -a --filter "name=$INFRASTRUCTURE_PREFIX" --format "{{.ID}} {{.Image}} {{.Names}}")
  if [ ${#containers[@]} -eq 0 ]; then
    log WARNING "No containers found for infrastructure: $INFRASTRUCTURE_PREFIX"
    echo
    return 0
  fi
  log "Removing related containers..."
  for container in "${containers[@]}"; do
    local id=$(echo "$container" | awk '{print $1}')
    local name=$(echo "$container" | awk '{print $3}')
    log "Stopping container $name ($id)..."
    docker stop "$id" || log "Failed to stop $name"
    log "Removing container $name ($id)..."
    docker rm "$id" || log " Failed to remove $name"
  done
  log SUCCESS "Infrastructure destroyed successfully!"
  echo
}

deploy_environments() {
  log "Deploying environments..."
  docker buildx create --name "${INFRASTRUCTURE_PREFIX}-builder" --use --driver docker-container --driver-opt network=host 2>/dev/null || log "Using existing buildx instance..."
  for package_dir in "${SCRIPTS_DIR}/../packages"/*; do
    [[ -d "$package_dir" ]] || continue
    dockerfile_path="${package_dir}/Dockerfile"
    if [[ -f "$dockerfile_path" ]]; then
      package_name=$(basename "$package_dir")
      for env in des prd; do
        log " -> Building and pushing for $env"
        docker buildx build \
          -f "$dockerfile_path" \
          -t "localhost:${REGISTRY_HOST_PORT}/${package_name}-${env}:latest" \
          --push \
          "${SCRIPTS_DIR}/.."
      done
    fi
  done
  docker buildx rm "${INFRASTRUCTURE_PREFIX}-builder"
  kubectl apply -f "${KIND_DES_PATH}"
  kubectl apply -f "${KIND_PRD_PATH}"
}

usage() {
  cat <<EOF
Usage: $0 [OPTION]

Options:
  create      Create the local container registry and kind cluster.
  destroy     Destroy the local container registry and kind cluster.
  deploy      Build all images from the manifested environments (if missing) and deploy them to the cluster.
  all         Run 'create' followed by 'deploy' for a full setup.
  help, -h    Show this help message.

Examples:
  $0 create         # Sets up the infrastructure only
  $0 deploy         # Deploys environments to an existing cluster
  $0 all            # Full setup: create cluster and deploy apps
  $0 destroy        # Tear down the infrastructure

Notes:
  - Ensure Docker is running before executing this script.
  - The script uses .env for configuration; adjust variables there if needed.
  - Kubernetes manifests are applied from the k8s/ folder.
EOF
  exit 0
}

main() {
  echo
  log "Current infrastructure prefix: ${INFRASTRUCTURE_PREFIX}"
  case "${1:-}" in
    create) create_infrastructure ;;
    destroy) destroy_infrastructure ;;
    deploy) deploy_environments ;;
    all)
      create_infrastructure
      deploy_environments
      ;;
    help|-h) usage ;;
    *) usage ;;
  esac
}

main "$1"

#!/bin/bash

set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="${SCRIPTS_DIR}/../terraform"
K8S_DIR="${SCRIPTS_DIR}/../k8s"

source "$SCRIPTS_DIR/../.env"

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

create_infrastructure() {
    log "Applying terraform resources..."
    terraform -chdir=$TERRAFORM_DIR apply --auto-approve
}

destroy_infrastructure() {
    log "Destroying terraform resources..."
    terraform -chdir=$TERRAFORM_DIR destroy --auto-approve
}

deploy_environments() {
  log "Deploying environments..."
  docker buildx create --name "${INFRASTRUCTURE_PREFIX}-builder" --use --driver docker-container --driver-opt network=host 2>/dev/null || log "Using existing buildx instance..."
  for env in "${ENVS[@]}"; do
    for package_dir in "${SCRIPTS_DIR}/../packages"/*; do
      [[ -d "$package_dir" ]] || continue
      dockerfile_path="${package_dir}/Dockerfile"
      if [[ -f "$dockerfile_path" ]]; then
        package_name=$(basename "$package_dir")
        log " -> Building and pushing for $env"
        docker buildx build \
          -f "$dockerfile_path" \
          -t "localhost:5000/${package_name}-${env}:latest" \
          --push \
          "${SCRIPTS_DIR}/.."
      fi
    done
    kubectl apply -f "${K8S_DIR}/${env}/"
  done
  docker buildx rm "${INFRASTRUCTURE_PREFIX}-builder"
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
#!/usr/bin/env bash

# Exit on error, unset vars are errors, and fail if any part of a pipe fails
set -euo pipefail

# Get absolute path of the script's directory
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TERRAFORM_DIR="${SCRIPTS_DIR}/../terraform"

# log function: prints messages with timestamp, log level, and color formatting
function log() {
  local level

  # Detect if first argument is a recognized log level (SUCCESS, WARNING, ERROR)
  # If so, set it as the level and shift it out; otherwise default to INFO
  case "${1^^}" in
    SUCCESS|WARNING|ERROR)
      level="${1^^}"
      shift
      ;;
    *)
      level="INFO"
      ;;
  esac

  local message="$*"
  
  # Assign ANSI color codes depending on the log level
  case "$level" in
    SUCCESS) color="\033[0;32m" ;; # Green
    WARNING) color="\033[0;33m" ;; # Yellow
    ERROR)   color="\033[0;31m" ;; # Red
    INFO)    color="\033[0;34m" ;; # Blue
  esac

  # Print formatted log: [time][level] message (with color and reset code)
  printf "%b[%s][%s]%b %s\n" "$color" "$(date +'%H:%M:%S')" "$level" "\033[0m" "$message"
}

function create_infrastructure() {
  log "Creating infrastructure..."
  terraform -chdir=$TERRAFORM_DIR apply --auto-approve
  log SUCCESS "Infrastructure created!"
}

function destroy_infrastructure() {
  log "Destroying infrastructure..."
  terraform -chdir=$TERRAFORM_DIR destroy --auto-approve
  log SUCCESS "Infrastructure destroyed!"
}

function deploy_environments() {
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
  log SUCCESS "Environments deployed!"
}

function usage() {
  local name=$(basename "$0")
  
  cat <<EOF
Usage: ${name} [OPTION]

Options:
  create      Create the infrastructure.
  destroy     Destroy the infrastructure.
  deploy      Deploy all environments and their applications.
  all         Run 'create' followed by 'deploy' for a full setup.
  help, -h    Show this help message.

Examples:
  ${name} create         # Sets up the infrastructure only
  ${name} destroy        # Tear down the infrastructure
  ${name} deploy         # Deploys environments to an existing infrastructure
  ${name} all            # Full setup: create infrastructure and deploy environments

Notes:
  - Ensure Docker is running before executing this script.
EOF
  exit 0
}

function main() {
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

main "${1:-help}"

#!/bin/bash

set -euo pipefail

SCRIPTS_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

INITIAL_DEPLOY_FILE="$SCRIPTS_DIRECTORY/../k8s/deploy.yaml"
NGINX_FILE="$SCRIPTS_DIRECTORY/../k8s/nginx.yaml"

INFRASTRUCTURE_PREFIX='on-premises-k8s'
KIND_CLUSTER_NAME="${INFRASTRUCTURE_PREFIX}-cluster"
KIND_NODE_IMAGE='kindest/node:v1.33.2'
KIND_CLUSTER_OPTS="--name ${KIND_CLUSTER_NAME} --image ${KIND_NODE_IMAGE}"
KIND_NETWORK='kind'

REGISTRY_NAME="${INFRASTRUCTURE_PREFIX}-registry"
REGISTRY_HOST_PORT='5000'
REGISTRY_IMAGE='registry:2'

log() {
  local level message
  case "${1^^}" in
    SUCCESS|WARNING|ERROR)
      level="${1^^}"
      shift
      ;;
    *)
      level="INFO"
      ;;
  esac
  message="$*"
  case "$level" in
    SUCCESS) color="\033[0;32m" ;; # Bold green
    WARNING) color="\033[0;33m" ;; # Bold yellow
    ERROR)   color="\033[0;31m" ;; # Bold red
    INFO)    color="\033[0;34m" ;; # Bold blue
  esac
  # printf "%b[%s]%b %s\n" "$color" "$level" "\033[0m" "$message"
  printf "%b[%s][%s]%b %s\n" "$color" "$(date +'%H:%M:%S')" "$level" "\033[0m" "$message"

}

add_container_registry() {
  local is_running=$(docker inspect -f '{{.State.Running}}' "${REGISTRY_NAME}" 2>/dev/null || true)
  if [ "${is_running}" = "true" ]; then
    log WARNING "Container registry ${REGISTRY_NAME} already running at http://localhost:${REGISTRY_HOST_PORT}/v2/_catalog"
    return 0
  fi
  docker rm -f "${REGISTRY_NAME}" 2>/dev/null || true
  log "Starting container registry ${REGISTRY_NAME} at port ${REGISTRY_HOST_PORT}..."
  docker run -d \
    --restart=always \
    -p "${REGISTRY_HOST_PORT}:5000" \
    --name "${REGISTRY_NAME}" \
    "${REGISTRY_IMAGE}"
  log "Container registry initialized at http://localhost:${REGISTRY_HOST_PORT}/v2/_catalog"
}

add_kind_cluster() {
  if kind get clusters | grep -q "^${KIND_CLUSTER_NAME}$"; then
    log WARNING "Kind cluster ${KIND_CLUSTER_NAME} already exists."
    return 0
  fi
  log "Creating kind cluster ${KIND_CLUSTER_NAME}..."
  cat <<EOF | kind create cluster ${KIND_CLUSTER_OPTS} --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:${REGISTRY_HOST_PORT}"]
    endpoint = ["http://${REGISTRY_NAME}:5000"]
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
- role: worker
- role: worker
  labels:
    role: app
- role: worker
  labels:
    role: ingress
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
EOF
}

apply_registry_configmap() {
  local name='local-registry-hosting'
  local namespace='kube-public'
  if kubectl get configmap ${name} -n ${namespace} &>/dev/null; then
    log WARNING "Registry ConfigMap is already installed"
    return 0
  fi
  log "Installing registry ConfigMap..."
  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: ${name}
  namespace: ${namespace}
data:
  localRegistryHosting.v1: |
    host: "localhost:${REGISTRY_HOST_PORT}"
    help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOF
}

connect_registry_to_cluster_network() {
  containers=$(docker network inspect ${KIND_NETWORK} -f "{{range .Containers}}{{.Name}} {{end}}")
  needs_connect="true"
  for c in $containers; do
    if [ "$c" = "${REGISTRY_NAME}" ]; then
      needs_connect="false"
    fi
  done
  if [ "${needs_connect}" = "false" ]; then               
    log WARNING "Container registry already connected to the cluster"
    return 0
  fi
  log "Connecting container registry to cluster network..."
  docker network connect "${KIND_NETWORK}" "${REGISTRY_NAME}" || true
}

apply_nginx_ingress() {
  if kubectl get namespace ingress-nginx &>/dev/null; then
    log WARNING "NGINX ingress is already installed"
    return 0
  fi
  log "Installing NGINX ingress..."
  kubectl apply -f "${NGINX_FILE}"
  kubectl wait -n ingress-nginx deployment ingress-nginx-controller --for=condition=available --timeout=120s
  kubectl rollout status -n ingress-nginx deployment/ingress-nginx-controller --timeout=600s
}

create_infrastructure() {
  log "Creating infrastructure..."
  add_container_registry
  add_kind_cluster
  apply_registry_configmap
  connect_registry_to_cluster_network
  apply_nginx_ingress
  log SUCCESS "Infrastructure created successfully!"
  echo  
}

destroy_infrastructure() {
  mapfile -t containers < <(docker ps -a --filter "name=$INFRASTRUCTURE_PREFIX" --format "{{.ID}} {{.Image}} {{.Names}}")
  if [ ${#containers[@]} -eq 0 ]; then
    log WARNING "No containers found for infrastructure: $INFRASTRUCTURE_PREFIX"
    echo
    exit 1
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

deploy_first_time() {
  log "Making initial deploy..."
  docker push localhost:5000/hello-app:1.0
  kubectl apply -f "${INITIAL_DEPLOY_FILE}"
}

choose_option() {
  options=(
    "Create infrastructure"
    "Destroy infrastructure"
    "Initial deploy"
    "Exit"
  )
  echo
  for opt in "${!options[@]}"; do
    printf "[%d] %s\n" $((opt + 1)) "${options[opt]}"
  done
  while true; do
    read -rp "Select option: " choice
    case "$choice" in
      1) echo; create_infrastructure; break ;;
      2) echo; destroy_infrastructure; break ;;
      3) echo; deploy_first_time; break ;;
      4) echo; break ;;
      *) tput cuu1; tput el ;;
    esac
  done
}

main() {
  log "Welcome to the provisioning menu, what do you want to do?"
  log "Current infrastructure prefix: ${INFRASTRUCTURE_PREFIX}"
  choose_option
}

trap 'log ERROR "Script failed at line $LINENO"' ERR

main

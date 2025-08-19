# Setup the relative path to script location and necessary scripts
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIND_CLUSTER_FILE="kind/cluster.yaml"
KIND_CLUSTER_DIR="$SCRIPTS_DIR/../$KIND_CLUSTER_FILE"

echo "Running at ${SCRIPTS_DIR}"
echo "Welcome, this script will provision the initial necessary infrastructure."

# Create initial Kind Cluster
echo "Creating Kind kubernetes cluster..."
kind create cluster --config="$KIND_CLUSTER_DIR"
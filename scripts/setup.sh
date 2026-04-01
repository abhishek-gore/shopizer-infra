#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "==> Setting up local Shopizer infrastructure..."

# Start Colima if not running
if ! colima status &>/dev/null; then
  echo "Starting Colima with Kubernetes..."
  colima start --kubernetes --cpu 4 --memory 8 --disk 50
else
  echo "Colima already running"
fi

# Set kubectl context
kubectl config use-context colima

# Install NGINX Ingress
echo ""
echo "==> Installing NGINX Ingress Controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s

# Build images from pre-built artifacts
echo ""
"$SCRIPT_DIR/build-images-prebuilt.sh"

# Apply Terraform
echo ""
echo "==> Applying Terraform..."
cd "$INFRA_ROOT/terraform/environments/local"
terraform init
terraform apply -auto-approve

# Deploy applications
echo ""
cd "$INFRA_ROOT"
"$SCRIPT_DIR/deploy.sh"

echo ""
echo "==> Setup complete!"
echo ""
echo "Add to /etc/hosts:"
echo "127.0.0.1 backend.local admin.local shop.local"
echo ""
echo "Access:"
echo "  Backend: http://backend.local"
echo "  Admin:   http://admin.local"
echo "  Shop:    http://shop.local"

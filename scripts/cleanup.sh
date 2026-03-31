#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "==> Cleaning up Shopizer infrastructure..."

# Delete K8s resources
kubectl delete -f "$INFRA_ROOT/kubernetes/ingress.yaml" --ignore-not-found
kubectl delete -f "$INFRA_ROOT/kubernetes/shop/" --ignore-not-found
kubectl delete -f "$INFRA_ROOT/kubernetes/admin/" --ignore-not-found
kubectl delete -f "$INFRA_ROOT/kubernetes/backend/" --ignore-not-found

# Destroy Terraform
cd "$INFRA_ROOT/terraform/environments/local"
terraform destroy -auto-approve

# Remove images
docker rmi shopizer-backend:latest shopizer-admin:latest shopizer-shop:latest --force 2>/dev/null || true

echo ""
echo "==> Cleanup complete!"
echo "To stop Colima: colima stop"

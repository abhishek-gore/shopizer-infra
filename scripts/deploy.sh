#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

IMAGE_TAG="${IMAGE_TAG:-latest}"

echo "==> Deploying to Kubernetes..."

# Apply manifests
kubectl apply -f "$INFRA_ROOT/kubernetes/namespace.yaml"
kubectl apply -f "$INFRA_ROOT/kubernetes/backend/"
kubectl apply -f "$INFRA_ROOT/kubernetes/admin/"
kubectl apply -f "$INFRA_ROOT/kubernetes/shop/"
kubectl apply -f "$INFRA_ROOT/kubernetes/ingress.yaml"

echo ""
echo "==> Waiting for deployments..."
kubectl wait --for=condition=available --timeout=300s \
  deployment/shopizer-backend \
  deployment/shopizer-admin \
  deployment/shopizer-shop \
  -n shopizer-local

echo ""
echo "==> Deployment complete!"
kubectl get pods -n shopizer-local

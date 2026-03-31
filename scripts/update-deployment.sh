#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

IMAGE_TAG="${IMAGE_TAG:-latest}"
DEPLOYMENT="${1:-all}"

echo "==> Updating deployment with tag: $IMAGE_TAG"

update_image() {
  local deployment=$1
  local container=$2
  local image=$3
  
  kubectl set image deployment/$deployment \
    $container=$image:$IMAGE_TAG \
    -n shopizer-local
}

case $DEPLOYMENT in
  backend)
    update_image shopizer-backend backend shopizer-backend
    ;;
  admin)
    update_image shopizer-admin admin shopizer-admin
    ;;
  shop)
    update_image shopizer-shop shop shopizer-shop
    ;;
  all)
    update_image shopizer-backend backend shopizer-backend
    update_image shopizer-admin admin shopizer-admin
    update_image shopizer-shop shop shopizer-shop
    ;;
  *)
    echo "Usage: $0 [backend|admin|shop|all]"
    exit 1
    ;;
esac

echo "==> Waiting for rollout..."
kubectl rollout status deployment/shopizer-$DEPLOYMENT -n shopizer-local --timeout=300s

echo "==> Update complete!"

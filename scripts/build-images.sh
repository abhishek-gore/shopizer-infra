#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
INFRA_ROOT="$WORKSPACE_ROOT/infra"
SHOPIZER_ROOT="$WORKSPACE_ROOT/shopizer-core"

IMAGE_TAG="${IMAGE_TAG:-latest}"

echo "==> Building Docker images from local repositories..."
echo "Workspace: $WORKSPACE_ROOT"
echo "Shopizer root: $SHOPIZER_ROOT"
echo "Image tag: $IMAGE_TAG"

# Backend
if [ -d "$SHOPIZER_ROOT/shopizer" ]; then
  echo ""
  echo "==> Building backend image..."
  docker build \
    -f "$INFRA_ROOT/docker/backend.Dockerfile" \
    -t shopizer-backend:$IMAGE_TAG \
    "$SHOPIZER_ROOT/shopizer"
else
  echo "⚠️  shopizer not found, skipping backend"
fi

# Admin
if [ -d "$SHOPIZER_ROOT/shopizer-admin" ]; then
  echo ""
  echo "==> Building admin image..."
  docker build \
    -f "$INFRA_ROOT/docker/admin.Dockerfile" \
    -t shopizer-admin:$IMAGE_TAG \
    "$SHOPIZER_ROOT/shopizer-admin"
else
  echo "⚠️  shopizer-admin not found, skipping admin"
fi

# Shop
if [ -d "$SHOPIZER_ROOT/shopizer-shop-reactjs" ]; then
  echo ""
  echo "==> Building shop image..."
  docker build \
    -f "$INFRA_ROOT/docker/shop.Dockerfile" \
    -t shopizer-shop:$IMAGE_TAG \
    "$SHOPIZER_ROOT/shopizer-shop-reactjs"
else
  echo "⚠️  shopizer-shop-reactjs not found, skipping shop"
fi

echo ""
echo "==> Build complete!"
docker images | grep shopizer

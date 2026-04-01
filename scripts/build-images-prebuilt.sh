#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

IMAGE_TAG="${IMAGE_TAG:-latest}"

echo "==> Building Docker images from pre-built artifacts..."

# Backend
echo "Building backend image..."
docker build \
  -f "$INFRA_ROOT/docker/backend-prebuilt.Dockerfile" \
  -t shopizer-backend:$IMAGE_TAG \
  "$INFRA_ROOT"

# Admin
echo "Building admin image..."
docker build \
  -f "$INFRA_ROOT/docker/admin-prebuilt.Dockerfile" \
  -t shopizer-admin:$IMAGE_TAG \
  "$INFRA_ROOT"

# Shop
echo "Building shop image..."
docker build \
  -f "$INFRA_ROOT/docker/shop-prebuilt.Dockerfile" \
  -t shopizer-shop:$IMAGE_TAG \
  "$INFRA_ROOT"

echo ""
echo "==> Build complete!"
docker images | grep shopizer

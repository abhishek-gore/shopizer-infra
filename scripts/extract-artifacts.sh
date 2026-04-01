#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "==> Extracting artifacts from Docker images..."

# Extract backend JAR
echo "Extracting backend JAR..."
docker create --name temp-backend shopizer-backend:latest
docker cp temp-backend:/app/app.jar "$INFRA_ROOT/artifacts/backend/app.jar"
docker rm temp-backend

# Extract admin build
echo "Extracting admin build..."
docker create --name temp-admin shopizer-admin:latest
docker cp temp-admin:/usr/share/nginx/html "$INFRA_ROOT/artifacts/admin/dist"
docker rm temp-admin

# Extract shop build
echo "Extracting shop build..."
docker create --name temp-shop shopizer-shop:latest
docker cp temp-shop:/usr/share/nginx/html "$INFRA_ROOT/artifacts/shop/build"
docker rm temp-shop

echo ""
echo "==> Artifacts extracted successfully!"
ls -lh "$INFRA_ROOT/artifacts/backend/"
ls -lh "$INFRA_ROOT/artifacts/admin/"
ls -lh "$INFRA_ROOT/artifacts/shop/"

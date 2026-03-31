#!/bin/bash
set -e

IMAGE_TAG="${IMAGE_TAG:-latest}"

echo "==> Loading images into Colima..."

# Check if using colima
if colima status &>/dev/null; then
  echo "Using Colima runtime"
  
  # Save images to tar
  docker save shopizer-backend:$IMAGE_TAG -o /tmp/backend.tar
  docker save shopizer-admin:$IMAGE_TAG -o /tmp/admin.tar
  docker save shopizer-shop:$IMAGE_TAG -o /tmp/shop.tar
  
  # Load into colima
  colima ssh -- sudo nerdctl -n k8s.io load -i /tmp/backend.tar
  colima ssh -- sudo nerdctl -n k8s.io load -i /tmp/admin.tar
  colima ssh -- sudo nerdctl -n k8s.io load -i /tmp/shop.tar
  
  # Cleanup
  rm /tmp/backend.tar /tmp/admin.tar /tmp/shop.tar
  
  echo "==> Images loaded into Colima"
else
  echo "Colima not running. Images already available in Docker."
fi

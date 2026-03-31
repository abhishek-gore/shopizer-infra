#!/bin/bash
set -e

echo "==> Shopizer Infrastructure Status"
echo ""

# Colima status
echo "📦 Colima:"
if colima status &>/dev/null; then
  colima status
else
  echo "  ❌ Not running"
fi

echo ""
echo "🐳 Docker Images:"
docker images | grep -E "shopizer|REPOSITORY"

echo ""
echo "☸️  Kubernetes Resources:"
kubectl get all -n shopizer-local 2>/dev/null || echo "  Namespace not found"

echo ""
echo "🌐 Ingress:"
kubectl get ingress -n shopizer-local 2>/dev/null || echo "  No ingress found"

echo ""
echo "📊 Resource Usage:"
kubectl top nodes 2>/dev/null || echo "  Metrics not available"
kubectl top pods -n shopizer-local 2>/dev/null || echo "  Metrics not available"

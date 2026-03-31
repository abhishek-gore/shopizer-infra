#!/bin/bash
set -e

SERVICE="${1:-backend}"
NAMESPACE="shopizer-local"

case $SERVICE in
  backend)
    POD=$(kubectl get pod -n $NAMESPACE -l app=shopizer-backend -o jsonpath='{.items[0].metadata.name}')
    kubectl logs -f -n $NAMESPACE $POD
    ;;
  admin)
    POD=$(kubectl get pod -n $NAMESPACE -l app=shopizer-admin -o jsonpath='{.items[0].metadata.name}')
    kubectl logs -f -n $NAMESPACE $POD
    ;;
  shop)
    POD=$(kubectl get pod -n $NAMESPACE -l app=shopizer-shop -o jsonpath='{.items[0].metadata.name}')
    kubectl logs -f -n $NAMESPACE $POD
    ;;
  *)
    echo "Usage: $0 [backend|admin|shop]"
    exit 1
    ;;
esac

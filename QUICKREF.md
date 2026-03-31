# Quick Reference Card

## 🚀 Essential Commands

### Setup (First Time)
```bash
cd infra
make setup
# or
./scripts/setup.sh
```

### Daily Development
```bash
# Build + Deploy
make update

# Check status
make status

# View logs
make logs SERVICE=backend
```

### Cleanup
```bash
make clean
colima stop
```

---

## 🌐 Access URLs

Add to `/etc/hosts`:
```
127.0.0.1 backend.local admin.local shop.local
```

- Backend API: http://backend.local
- Admin UI: http://admin.local  
- Shop UI: http://shop.local

---

## 📂 File Locations

| Component | Path |
|-----------|------|
| Dockerfiles | `infra/docker/` |
| K8s Manifests | `infra/kubernetes/` |
| Terraform | `infra/terraform/` |
| Scripts | `infra/scripts/` |
| CI/CD | `infra/.github/`, `.gitlab-ci.yml`, `Jenkinsfile` |

---

## 🔧 Common Tasks

### Rebuild Single Service
```bash
# Backend
docker build -f docker/backend.Dockerfile -t shopizer-backend:latest ../shopizer
./scripts/load-images.sh
kubectl rollout restart deployment/shopizer-backend -n shopizer-local

# Admin
docker build -f docker/admin.Dockerfile -t shopizer-admin:latest ../shopizer-admin
./scripts/load-images.sh
kubectl rollout restart deployment/shopizer-admin -n shopizer-local

# Shop
docker build -f docker/shop.Dockerfile -t shopizer-shop:latest ../shopizer-shop-reactjs
./scripts/load-images.sh
kubectl rollout restart deployment/shopizer-shop -n shopizer-local
```

### Debug
```bash
# Pod status
kubectl get pods -n shopizer-local

# Describe pod
kubectl describe pod -n shopizer-local <pod-name>

# Logs
kubectl logs -n shopizer-local <pod-name>

# Shell access
kubectl exec -it -n shopizer-local <pod-name> -- /bin/sh

# Port forward
kubectl port-forward -n shopizer-local svc/shopizer-backend 8080:80
```

### Verify Images in Colima
```bash
colima ssh -- sudo nerdctl -n k8s.io images | grep shopizer
```

---

## 🎯 Image Tag Strategy

### Development
```bash
make build  # Uses IMAGE_TAG=latest
```

### Commit-based
```bash
IMAGE_TAG=$(git rev-parse --short HEAD) make build
```

### Version Release
```bash
IMAGE_TAG=v1.2.3 make build
```

---

## 📊 Resource Monitoring

```bash
# Node resources
kubectl top nodes

# Pod resources
kubectl top pods -n shopizer-local

# Events
kubectl get events -n shopizer-local --sort-by='.lastTimestamp'
```

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| Colima not running | `colima start --kubernetes --cpu 4 --memory 8` |
| Images not found | `./scripts/load-images.sh` |
| Pods not starting | `kubectl describe pod -n shopizer-local <pod>` |
| Ingress not working | Check `/etc/hosts` and `kubectl get ingress -n shopizer-local` |
| DNS not resolving | Verify ingress-nginx controller is running |

---

## 📦 What Gets Created

- ✅ 3 Docker images (backend, admin, shop)
- ✅ 1 Kubernetes namespace
- ✅ 3 Deployments
- ✅ 3 Services
- ✅ 1 Ingress
- ✅ NGINX Ingress Controller

---

## 🎓 Learning Resources

- Colima: https://github.com/abiosoft/colima
- Kubernetes: https://kubernetes.io/docs/
- Terraform: https://terraform.io/docs
- NGINX Ingress: https://kubernetes.github.io/ingress-nginx/

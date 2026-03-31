# Shopizer Infrastructure - Complete Guide

## 📁 Repository Structure

```
workspace/
├── shopizer/                    # Backend Java application
├── shopizer-admin/              # Angular admin frontend
├── shopizer-shop-reactjs/       # React shop frontend
└── infra/                       # ⭐ Infrastructure repository
    ├── .github/
    │   └── workflows/
    │       └── deploy.yaml      # GitHub Actions pipeline
    ├── .gitlab-ci.yml           # GitLab CI pipeline
    ├── Jenkinsfile              # Jenkins pipeline
    ├── docker/
    │   ├── backend.Dockerfile   # Multi-stage Java build
    │   ├── admin.Dockerfile     # Angular + Nginx
    │   ├── shop.Dockerfile      # React + Nginx
    │   └── nginx.conf           # Nginx config for frontends
    ├── kubernetes/
    │   ├── namespace.yaml
    │   ├── ingress.yaml         # Routes for all services
    │   ├── backend/
    │   │   ├── deployment.yaml
    │   │   ├── service.yaml
    │   │   └── configmap.yaml
    │   ├── admin/
    │   │   ├── deployment.yaml
    │   │   └── service.yaml
    │   └── shop/
    │       ├── deployment.yaml
    │       └── service.yaml
    ├── terraform/
    │   ├── modules/
    │   │   └── namespace/
    │   │       ├── main.tf
    │   │       ├── variables.tf
    │   │       └── outputs.tf
    │   └── environments/
    │       └── local/
    │           ├── providers.tf
    │           ├── main.tf
    │           ├── variables.tf
    │           └── outputs.tf
    ├── scripts/
    │   ├── setup.sh             # Full bootstrap
    │   ├── build-images.sh      # Build all Docker images
    │   ├── load-images.sh       # Load into Colima
    │   ├── deploy.sh            # Deploy to K8s
    │   ├── cleanup.sh           # Remove all resources
    │   ├── update-deployment.sh # Rolling update
    │   └── logs.sh              # View service logs
    ├── environments/
    │   └── local/
    │       ├── .env
    │       └── README.md
    └── README.md
```

---

## 🚀 Quick Start

### Prerequisites
```bash
brew install colima docker terraform kubectl
```

### One-Command Setup
```bash
cd infra
./scripts/setup.sh
```

### Manual Setup
```bash
# 1. Start Colima with Kubernetes
colima start --kubernetes --cpu 4 --memory 8 --disk 50

# 2. Set kubectl context
kubectl config use-context colima

# 3. Build Docker images from local repos
cd infra
./scripts/build-images.sh

# 4. Load images into Colima
./scripts/load-images.sh

# 5. Provision infrastructure
terraform -chdir=terraform/environments/local init
terraform -chdir=terraform/environments/local apply

# 6. Deploy applications
./scripts/deploy.sh
```

### Configure Local DNS
Add to `/etc/hosts`:
```
127.0.0.1 backend.local admin.local shop.local
```

---

## 🏗️ Architecture

### Docker Build Strategy

All images are built using **multi-stage builds** with local repository paths:

#### Backend (Java)
- **Build Context**: `../shopizer`
- **Dockerfile**: `infra/docker/backend.Dockerfile`
- **Process**:
  1. Maven builds JAR from source
  2. Runtime image copies JAR
  3. Uses Eclipse Temurin JRE 17

#### Admin (Angular)
- **Build Context**: `../shopizer-admin`
- **Dockerfile**: `infra/docker/admin.Dockerfile`
- **Process**:
  1. npm builds production bundle
  2. Nginx serves static files
  3. API proxy to backend

#### Shop (React)
- **Build Context**: `../shopizer-shop-reactjs`
- **Dockerfile**: `infra/docker/shop.Dockerfile`
- **Process**:
  1. npm builds production bundle
  2. Nginx serves static files
  3. API proxy to backend

### Image Management

Images are **never pushed to a registry**. Instead:

1. Built locally with Docker
2. Saved as tar archives
3. Loaded into Colima's containerd namespace (`k8s.io`)
4. Referenced with `imagePullPolicy: Never` in K8s

### Kubernetes Architecture

```
┌─────────────────────────────────────────┐
│         NGINX Ingress Controller        │
└─────────────────────────────────────────┘
           │              │              │
    backend.local   admin.local    shop.local
           │              │              │
           ▼              ▼              ▼
    ┌──────────┐   ┌──────────┐   ┌──────────┐
    │ Backend  │   │  Admin   │   │   Shop   │
    │ Service  │   │ Service  │   │ Service  │
    └──────────┘   └──────────┘   └──────────┘
           │              │              │
           ▼              ▼              ▼
    ┌──────────┐   ┌──────────┐   ┌──────────┐
    │ Backend  │   │  Admin   │   │   Shop   │
    │   Pod    │   │   Pod    │   │   Pod    │
    └──────────┘   └──────────┘   └──────────┘
```

---

## 🔄 CI/CD Workflow

### Local Development Flow

```
┌─────────────────┐
│ Code Changes    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Build Artifacts │ ← Maven/npm builds
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Build Images    │ ← Docker multi-stage
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Load to Colima  │ ← nerdctl load
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Deploy to K8s   │ ← kubectl apply
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Verify & Test   │
└─────────────────┘
```

### CI/CD Pipeline Stages

#### Stage 1: Build Artifacts
```bash
# Backend
cd ../shopizer
mvn clean package -DskipTests

# Admin
cd ../shopizer-admin
npm ci && npm run build -- --configuration production

# Shop
cd ../shopizer-shop-reactjs
npm ci && npm run build
```

#### Stage 2: Package Images
```bash
cd infra
export IMAGE_TAG=$COMMIT_SHA
./scripts/build-images.sh
```

#### Stage 3: Load Images
```bash
./scripts/load-images.sh
```

#### Stage 4: Deploy
```bash
./scripts/deploy.sh
```

### Supported CI Systems

- **GitHub Actions**: `.github/workflows/deploy.yaml`
- **GitLab CI**: `.gitlab-ci.yml`
- **Jenkins**: `Jenkinsfile`

All pipelines follow the same 4-stage pattern.

---

## 🛠️ Common Operations

### Build Single Service
```bash
# Backend only
docker build -f docker/backend.Dockerfile -t shopizer-backend:latest ../shopizer

# Admin only
docker build -f docker/admin.Dockerfile -t shopizer-admin:latest ../shopizer-admin

# Shop only
docker build -f docker/shop.Dockerfile -t shopizer-shop:latest ../shopizer-shop-reactjs
```

### Update Deployment
```bash
# Build new image
export IMAGE_TAG=$(git rev-parse --short HEAD)
./scripts/build-images.sh
./scripts/load-images.sh

# Rolling update
./scripts/update-deployment.sh all
# Or specific service
./scripts/update-deployment.sh backend
```

### View Logs
```bash
./scripts/logs.sh backend
./scripts/logs.sh admin
./scripts/logs.sh shop
```

### Debug Pod
```bash
kubectl exec -it -n shopizer-local \
  $(kubectl get pod -n shopizer-local -l app=shopizer-backend -o jsonpath='{.items[0].metadata.name}') \
  -- /bin/sh
```

### Port Forward (Bypass Ingress)
```bash
# Backend
kubectl port-forward -n shopizer-local svc/shopizer-backend 8080:80

# Admin
kubectl port-forward -n shopizer-local svc/shopizer-admin 8081:80

# Shop
kubectl port-forward -n shopizer-local svc/shopizer-shop 8082:80
```

---

## 🎯 Version Tagging Strategy

### Development (Default)
```bash
IMAGE_TAG=latest
```

### Commit-based
```bash
IMAGE_TAG=$(git rev-parse --short HEAD)
./scripts/build-images.sh
```

### Semantic Versioning
```bash
IMAGE_TAG=v1.2.3
./scripts/build-images.sh
```

### Update K8s Manifests
Edit deployment files to use specific tag:
```yaml
spec:
  containers:
  - name: backend
    image: shopizer-backend:v1.2.3
    imagePullPolicy: Never
```

---

## 🔧 Customization

### Add Database (PostgreSQL)

1. Create `kubernetes/postgres/` directory
2. Add deployment, service, PVC
3. Update backend configmap:
```yaml
data:
  application.properties: |
    spring.datasource.url=jdbc:postgresql://postgres:5432/shopizer
    spring.datasource.username=shopizer
    spring.datasource.password=password
```

### Add Redis Cache

1. Create `kubernetes/redis/` directory
2. Update backend to use Redis
3. Add Redis service endpoint

### Enable Hot Reload (Dev Mode)

Mount local code as volumes:
```yaml
spec:
  containers:
  - name: backend
    volumeMounts:
    - name: code
      mountPath: /app
  volumes:
  - name: code
    hostPath:
      path: /Users/abhishekgore/Projects/shopizer
```

---

## 🧹 Cleanup

### Remove Deployments Only
```bash
kubectl delete -f kubernetes/ingress.yaml
kubectl delete -f kubernetes/shop/
kubectl delete -f kubernetes/admin/
kubectl delete -f kubernetes/backend/
```

### Full Cleanup
```bash
./scripts/cleanup.sh
```

### Stop Colima
```bash
colima stop
```

### Delete Colima VM
```bash
colima delete
```

---

## 🐛 Troubleshooting

### Images Not Found
```bash
# Verify images in Colima
colima ssh -- sudo nerdctl -n k8s.io images | grep shopizer

# Reload if missing
./scripts/load-images.sh
```

### Pods Not Starting
```bash
# Check events
kubectl describe pod -n shopizer-local <pod-name>

# Check logs
kubectl logs -n shopizer-local <pod-name>
```

### Ingress Not Working
```bash
# Check ingress controller
kubectl get pods -n ingress-nginx

# Check ingress resource
kubectl describe ingress -n shopizer-local shopizer-ingress

# Test service directly
kubectl port-forward -n shopizer-local svc/shopizer-backend 8080:80
curl localhost:8080
```

### DNS Not Resolving
```bash
# Verify /etc/hosts
cat /etc/hosts | grep local

# Test with curl
curl -H "Host: backend.local" http://localhost
```

---

## 📊 Resource Requirements

### Minimum
- CPU: 4 cores
- Memory: 8 GB
- Disk: 50 GB

### Recommended
- CPU: 6 cores
- Memory: 12 GB
- Disk: 100 GB

### Per Service
- Backend: 512Mi-1Gi memory, 500m-1000m CPU
- Admin: 128Mi-256Mi memory, 100m-200m CPU
- Shop: 128Mi-256Mi memory, 100m-200m CPU

---

## 🔐 Security Notes

- All services run in isolated namespace
- No external registry (images stay local)
- ConfigMaps for non-sensitive config
- Use Secrets for sensitive data (not included)
- Network policies can be added for pod isolation

---

## 📚 Additional Resources

- [Colima Documentation](https://github.com/abiosoft/colima)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Terraform Kubernetes Provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)

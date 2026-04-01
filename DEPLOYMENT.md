# Shopizer Deployment Guide

## Overview

This guide explains the complete deployment flow for Shopizer microservices on local Kubernetes using Colima. The infrastructure uses Docker for containerization, Kubernetes for orchestration, Terraform for infrastructure provisioning, and NGINX Ingress for routing.

## Architecture Components

### Technology Stack
- **Container Runtime**: Colima (lightweight Docker Desktop alternative for macOS)
- **Orchestration**: Kubernetes (embedded in Colima)
- **Infrastructure as Code**: Terraform
- **Ingress Controller**: NGINX Ingress
- **Build Tool**: Docker
- **Image Registry**: Local (no external registry)

### Services
1. **Backend** - Java Spring Boot API (Port 8080)
2. **Admin** - Angular admin dashboard (Port 80)
3. **Shop** - React storefront (Port 80)

## Deployment Flow

### Phase 1: Environment Setup

```
Developer Machine
    ↓
Colima VM Start (--kubernetes --cpu 4 --memory 8)
    ↓
Kubernetes Cluster Initialized
    ↓
NGINX Ingress Controller Installed
```

**What happens:**
- Colima starts a lightweight VM with Kubernetes enabled
- kubectl context switches to `colima`
- NGINX Ingress Controller deployed to `ingress-nginx` namespace
- Waits for ingress controller to be ready (timeout: 300s)

**Script:** `scripts/setup.sh`

### Phase 2: Image Building

```
Source Code Repositories
    ↓
Docker Build (Multi-stage builds)
    ↓
Local Docker Images Created
```

**Build Process:**

1. **Backend Image** (`shopizer-backend:latest`)
   - Source: `../shopizer-core/shopizer/`
   - Dockerfile: `docker/backend.Dockerfile`
   - Build stages:
     - Stage 1: Maven build with JDK 17
     - Stage 2: Runtime with JRE 17
   - Output: Spring Boot JAR

2. **Admin Image** (`shopizer-admin:latest`)
   - Source: `../shopizer-core/shopizer-admin/`
   - Dockerfile: `docker/admin.Dockerfile`
   - Build: Angular production build with NGINX

3. **Shop Image** (`shopizer-shop:latest`)
   - Source: `../shopizer-core/shopizer-shop-reactjs/`
   - Dockerfile: `docker/shop.Dockerfile`
   - Build: React production build with NGINX

**Script:** `scripts/build-images.sh`

**Environment Variables:**
- `IMAGE_TAG` - Image tag (default: `latest`)

### Phase 3: Image Loading

```
Docker Images (Host)
    ↓
docker save → TAR files
    ↓
colima ssh → nerdctl load
    ↓
Images Available in Kubernetes
```

**What happens:**
- Images exported from Docker to TAR archives
- TAR files transferred to Colima VM
- Images loaded into containerd (k8s.io namespace)
- TAR files cleaned up

**Why this step?**
Colima uses containerd as the Kubernetes runtime, which is separate from Docker. Images must be explicitly transferred.

**Script:** `scripts/load-images.sh`

### Phase 4: Infrastructure Provisioning

```
Terraform Configuration
    ↓
terraform init
    ↓
terraform apply
    ↓
Kubernetes Namespace Created
```

**Terraform Resources:**
- **Namespace**: `shopizer-local`
- **Labels**: 
  - `environment: local`
  - `managed-by: terraform`

**Location:** `terraform/environments/local/`

**Modules Used:**
- `namespace` - Creates and manages Kubernetes namespace

### Phase 5: Application Deployment

```
Kubernetes Manifests
    ↓
kubectl apply
    ↓
Pods/Services/Ingress Created
    ↓
Wait for Deployments Ready
```

**Deployment Order:**

1. **Namespace** (`kubernetes/namespace.yaml`)
   - Creates `shopizer-local` namespace

2. **Backend** (`kubernetes/backend/`)
   - ConfigMap: Application configuration
   - ConfigMap: Database configuration (H2 in-memory)
   - Deployment: 1 replica, 512Mi-1Gi memory
   - Service: ClusterIP on port 80 → 8080
   - Environment:
     - `SPRING_PROFILES_ACTIVE=local`
     - `POPULATE_TEST_DATA=true`

3. **Admin** (`kubernetes/admin/`)
   - ConfigMap: NGINX configuration
   - Deployment: 1 replica
   - Service: ClusterIP on port 80

4. **Shop** (`kubernetes/shop/`)
   - ConfigMap: NGINX configuration
   - Deployment: 1 replica
   - Service: ClusterIP on port 80

5. **Ingress** (`kubernetes/ingress.yaml`)
   - Routes traffic based on hostname:
     - `backend.local` → shopizer-backend:80
     - `admin.local` → shopizer-admin:80
     - `shop.local` → shopizer-shop:80

**Script:** `scripts/deploy.sh`

**Wait Conditions:**
- All deployments must reach `available` condition
- Timeout: 300 seconds

## Complete Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. SETUP PHASE                                                   │
│    ./scripts/setup.sh                                            │
│    ├─ Start Colima VM                                            │
│    ├─ Install NGINX Ingress                                      │
│    └─ Set kubectl context                                        │
└────────────────────────────┬─────────────────────────────────────┘
                             │
┌────────────────────────────▼─────────────────────────────────────┐
│ 2. BUILD PHASE                                                    │
│    ./scripts/build-images.sh                                     │
│    ├─ Build backend (Maven + JDK 17)                             │
│    ├─ Build admin (Angular + NGINX)                              │
│    └─ Build shop (React + NGINX)                                 │
└────────────────────────────┬─────────────────────────────────────┘
                             │
┌────────────────────────────▼─────────────────────────────────────┐
│ 3. LOAD PHASE                                                     │
│    ./scripts/load-images.sh                                      │
│    ├─ Export images to TAR                                       │
│    ├─ Load into Colima containerd                                │
│    └─ Cleanup TAR files                                          │
└────────────────────────────┬─────────────────────────────────────┘
                             │
┌────────────────────────────▼─────────────────────────────────────┐
│ 4. PROVISION PHASE                                                │
│    terraform init && terraform apply                             │
│    └─ Create shopizer-local namespace                            │
└────────────────────────────┬─────────────────────────────────────┘
                             │
┌────────────────────────────▼─────────────────────────────────────┐
│ 5. DEPLOY PHASE                                                   │
│    ./scripts/deploy.sh                                           │
│    ├─ Apply namespace                                            │
│    ├─ Deploy backend (+ ConfigMaps)                              │
│    ├─ Deploy admin (+ ConfigMap)                                 │
│    ├─ Deploy shop (+ ConfigMap)                                  │
│    ├─ Apply ingress rules                                        │
│    └─ Wait for all deployments                                   │
└────────────────────────────┬─────────────────────────────────────┘
                             │
┌────────────────────────────▼─────────────────────────────────────┐
│ 6. ACCESS                                                         │
│    Add to /etc/hosts:                                            │
│    127.0.0.1 backend.local admin.local shop.local                │
│                                                                   │
│    Access URLs:                                                   │
│    • http://backend.local                                        │
│    • http://admin.local                                          │
│    • http://shop.local                                           │
└───────────────────────────────────────────────────────────────────┘
```

## Network Flow

```
Browser Request
    ↓
http://backend.local
    ↓
/etc/hosts → 127.0.0.1
    ↓
Colima Port Forward (80)
    ↓
NGINX Ingress Controller
    ↓
Ingress Rules (host-based routing)
    ↓
Service (ClusterIP)
    ↓
Pod (Container)
```

## Resource Specifications

### Backend
- **Image**: `shopizer-backend:latest`
- **Pull Policy**: `Never` (local only)
- **Replicas**: 1
- **Resources**:
  - Requests: 500m CPU, 512Mi memory
  - Limits: 1000m CPU, 1Gi memory
- **Port**: 8080
- **Database**: H2 in-memory (configured via ConfigMap)

### Admin & Shop
- **Images**: `shopizer-admin:latest`, `shopizer-shop:latest`
- **Pull Policy**: `Never`
- **Replicas**: 1
- **Port**: 80 (NGINX)

## Configuration Management

### ConfigMaps

1. **backend-config** - Application properties
2. **backend-db-config** - Database connection (H2)
3. **admin-nginx-config** - NGINX server configuration
4. **shop-nginx-config** - NGINX server configuration

### Volume Mounts

Backend deployment mounts database config:
```yaml
volumeMounts:
- name: db-config
  mountPath: /app/BOOT-INF/classes/profiles/local/database.properties
  subPath: database.properties
```

## Commands Reference

### One-Command Deployment
```bash
./scripts/setup.sh
```

### Step-by-Step Deployment
```bash
# 1. Start Colima
colima start --kubernetes --cpu 4 --memory 8

# 2. Build images
./scripts/build-images.sh

# 3. Load images
./scripts/load-images.sh

# 4. Provision infrastructure
terraform -chdir=terraform/environments/local init
terraform -chdir=terraform/environments/local apply

# 5. Deploy applications
./scripts/deploy.sh
```

### Verification Commands
```bash
# Check Colima status
colima status

# Check pods
kubectl get pods -n shopizer-local

# Check services
kubectl get svc -n shopizer-local

# Check ingress
kubectl get ingress -n shopizer-local

# View logs
kubectl logs -f deployment/shopizer-backend -n shopizer-local

# Check deployment status
./scripts/status.sh
```

### Update Deployment
```bash
# Rebuild and update specific service
IMAGE_TAG=v2 ./scripts/build-images.sh
./scripts/load-images.sh
./scripts/update-deployment.sh backend
```

### Cleanup
```bash
# Remove all resources
./scripts/cleanup.sh

# Stop Colima
colima stop

# Delete Colima VM
colima delete
```

## Troubleshooting

### Images Not Found
**Symptom**: `ImagePullBackOff` or `ErrImagePull`

**Solution**:
```bash
# Verify images in Colima
colima ssh -- sudo nerdctl -n k8s.io images | grep shopizer

# Reload images
./scripts/load-images.sh
```

### Ingress Not Working
**Symptom**: Cannot access `*.local` domains

**Solution**:
```bash
# Check /etc/hosts
cat /etc/hosts | grep local

# Check ingress controller
kubectl get pods -n ingress-nginx

# Check ingress resource
kubectl describe ingress shopizer-ingress -n shopizer-local
```

### Pod Crashes
**Symptom**: `CrashLoopBackOff`

**Solution**:
```bash
# Check logs
kubectl logs deployment/shopizer-backend -n shopizer-local

# Check events
kubectl get events -n shopizer-local --sort-by='.lastTimestamp'

# Describe pod
kubectl describe pod <pod-name> -n shopizer-local
```

### Resource Constraints
**Symptom**: Pods pending or OOMKilled

**Solution**:
```bash
# Increase Colima resources
colima stop
colima start --kubernetes --cpu 6 --memory 12

# Check resource usage
kubectl top nodes
kubectl top pods -n shopizer-local
```

## Environment Variables

### Build Time
- `IMAGE_TAG` - Docker image tag (default: `latest`)

### Runtime (Backend)
- `SPRING_PROFILES_ACTIVE` - Spring profile (set to `local`)
- `POPULATE_TEST_DATA` - Load test data (set to `true`)

## File Structure

```
infra/
├── docker/                      # Dockerfiles
│   ├── backend.Dockerfile       # Java multi-stage build
│   ├── admin.Dockerfile         # Angular + NGINX
│   └── shop.Dockerfile          # React + NGINX
├── kubernetes/                  # K8s manifests
│   ├── namespace.yaml           # Namespace definition
│   ├── backend/                 # Backend resources
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── configmap.yaml
│   │   └── db-configmap.yaml
│   ├── admin/                   # Admin resources
│   ├── shop/                    # Shop resources
│   └── ingress.yaml             # Ingress rules
├── terraform/                   # Infrastructure as Code
│   ├── modules/
│   │   └── namespace/           # Namespace module
│   └── environments/
│       └── local/               # Local environment
│           ├── main.tf
│           ├── providers.tf
│           ├── variables.tf
│           └── outputs.tf
└── scripts/                     # Automation scripts
    ├── setup.sh                 # Complete setup
    ├── build-images.sh          # Build Docker images
    ├── load-images.sh           # Load images to Colima
    ├── deploy.sh                # Deploy to K8s
    ├── cleanup.sh               # Remove all resources
    ├── status.sh                # Check deployment status
    ├── logs.sh                  # View logs
    └── update-deployment.sh     # Update specific service
```

## Prerequisites

### Required Tools
- **Colima** - Container runtime
- **Docker** - Image building
- **Terraform** - Infrastructure provisioning
- **kubectl** - Kubernetes CLI
- **Git** - Version control

### Installation (macOS)
```bash
brew install colima docker terraform kubectl
```

### System Requirements
- **CPU**: 4+ cores
- **Memory**: 8+ GB
- **Disk**: 50+ GB free space

## Security Considerations

### Local Development Only
This setup is designed for local development and should NOT be used in production:
- No TLS/SSL encryption
- No authentication/authorization
- No network policies
- No resource quotas
- No pod security policies
- H2 in-memory database (data lost on restart)

### Production Checklist
For production deployment, implement:
- [ ] TLS certificates and HTTPS
- [ ] Authentication (OAuth2, JWT)
- [ ] Network policies
- [ ] Resource quotas and limits
- [ ] Pod security standards
- [ ] Persistent database (MySQL, PostgreSQL)
- [ ] Secrets management (Vault, Sealed Secrets)
- [ ] Monitoring and logging
- [ ] Backup and disaster recovery
- [ ] CI/CD pipeline

## CI/CD Integration

The repository includes CI/CD configurations:
- **GitHub Actions**: `.github/workflows/`
- **GitLab CI**: `.gitlab-ci.yml`
- **Jenkins**: `Jenkinsfile`

These can be adapted for automated deployments.

## Additional Resources

- [Colima Documentation](https://github.com/abiosoft/colima)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Terraform Kubernetes Provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)

## Support

For issues or questions:
1. Check logs: `./scripts/logs.sh`
2. Check status: `./scripts/status.sh`
3. Review troubleshooting section above
4. Check existing documentation: `ARCHITECTURE.md`, `GUIDE.md`

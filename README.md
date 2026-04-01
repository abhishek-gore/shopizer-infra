# Shopizer Local Infrastructure

Local Kubernetes infrastructure for Shopizer microservices using Colima, Terraform, and Kubernetes.

## Prerequisites

- Colima
- Docker
- kubectl

## Quick Start

This repository includes pre-built artifacts, so you don't need to clone the source repositories.

```bash
cd infra

# Bootstrap everything
./scripts/setup.sh

# Or step by step:
colima start --kubernetes --cpu 4 --memory 8
./scripts/build-images-prebuilt.sh
terraform -chdir=terraform/environments/local init
terraform -chdir=terraform/environments/local apply
./scripts/deploy.sh
```

## Building from Source (Optional)

If you have the source repositories:

```bash
# Build from source
./scripts/build-images.sh

# Extract artifacts for distribution
./scripts/extract-artifacts.sh
```

## Access Applications

Add to `/etc/hosts`:
```
127.0.0.1 backend.local admin.local shop.local
```

- Backend API: http://backend.local
- Admin UI: http://admin.local
- Shop UI: http://shop.local

## Cleanup

```bash
./scripts/cleanup.sh
```

## Structure

```
infra/
├── artifacts/           # Pre-built JARs and build files
│   ├── backend/        # Backend JAR
│   ├── admin/          # Admin UI build
│   └── shop/           # Shop UI build
├── docker/              # Dockerfiles for each service
├── kubernetes/          # K8s manifests
├── terraform/           # Infrastructure as code
├── scripts/             # Automation scripts
└── environments/        # Environment configs
```

## Scripts

- `setup.sh` - Complete setup (Colima + build + deploy)
- `build-images-prebuilt.sh` - Build from pre-built artifacts (default)
- `build-images.sh` - Build from source repositories (requires source)
- `extract-artifacts.sh` - Extract artifacts from built images
- `deploy.sh` - Deploy to Kubernetes
- `cleanup.sh` - Clean up everything

## Git LFS

Large artifacts are stored using Git LFS. Install it if needed:

```bash
brew install git-lfs
git lfs install
git lfs pull
```

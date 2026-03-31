# Shopizer Local Infrastructure

Local Kubernetes infrastructure for Shopizer microservices using Colima, Terraform, and Kubernetes.

## Prerequisites

- Colima
- Docker
- Terraform
- kubectl
- Helm (optional)

## Quick Start

```bash
# From workspace root
cd infra

# Bootstrap everything
./scripts/setup.sh

# Or step by step:
colima start --kubernetes --cpu 4 --memory 8
./scripts/build-images.sh
./scripts/load-images.sh
terraform -chdir=terraform/environments/local init
terraform -chdir=terraform/environments/local apply
./scripts/deploy.sh
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
├── docker/              # Dockerfiles for each service
├── kubernetes/          # K8s manifests
├── terraform/           # Infrastructure as code
├── scripts/             # Automation scripts
└── environments/        # Environment configs
```

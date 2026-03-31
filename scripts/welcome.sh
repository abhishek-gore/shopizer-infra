#!/bin/bash

cat << 'EOF'
╔═══════════════════════════════════════════════════════════════╗
║           Shopizer Local Infrastructure Setup                 ║
║                                                                ║
║  Complete CI/CD + Kubernetes infrastructure for microservices ║
╚═══════════════════════════════════════════════════════════════╝

📁 WORKSPACE STRUCTURE
──────────────────────────────────────────────────────────────────
workspace/
├── shopizer/                 ← Backend (Java)
├── shopizer-admin/           ← Admin UI (Angular)
├── shopizer-shop-reactjs/    ← Shop UI (React)
└── infra/                    ← Infrastructure (YOU ARE HERE)

🚀 QUICK START
──────────────────────────────────────────────────────────────────
1. Run full setup:
   $ ./scripts/setup.sh

2. Add to /etc/hosts:
   127.0.0.1 backend.local admin.local shop.local

3. Access applications:
   • Backend: http://backend.local
   • Admin:   http://admin.local
   • Shop:    http://shop.local

📚 DOCUMENTATION
──────────────────────────────────────────────────────────────────
• README.md         - Quick start
• GUIDE.md          - Complete guide (recommended)
• QUICKREF.md       - Daily reference
• ARCHITECTURE.md   - System architecture
• IMPLEMENTATION.md - What was built

🛠️ COMMON COMMANDS
──────────────────────────────────────────────────────────────────
make setup          Full bootstrap
make build          Build Docker images
make deploy         Deploy to Kubernetes
make update         Rebuild + redeploy
make status         Check infrastructure
make logs           View service logs
make clean          Remove everything

📋 MANUAL STEPS
──────────────────────────────────────────────────────────────────
colima start --kubernetes --cpu 4 --memory 8
./scripts/build-images.sh
./scripts/load-images.sh
terraform -chdir=terraform/environments/local init
terraform -chdir=terraform/environments/local apply
./scripts/deploy.sh

🔧 UTILITIES
──────────────────────────────────────────────────────────────────
./scripts/status.sh              Check everything
./scripts/logs.sh backend        View backend logs
./scripts/update-deployment.sh   Rolling update

🎯 WHAT THIS DOES
──────────────────────────────────────────────────────────────────
✓ Builds Docker images from local repos
✓ Loads images into Colima (no registry)
✓ Provisions Kubernetes namespace via Terraform
✓ Deploys 3 microservices with Ingress
✓ Provides CI/CD pipeline templates
✓ Simulates production environment locally

📦 REQUIREMENTS
──────────────────────────────────────────────────────────────────
• Colima
• Docker
• Terraform
• kubectl
• 4+ CPU cores, 8+ GB RAM

🎓 GETTING HELP
──────────────────────────────────────────────────────────────────
Read GUIDE.md for detailed documentation
Run ./scripts/status.sh to diagnose issues

──────────────────────────────────────────────────────────────────
Ready to deploy! Run: ./scripts/setup.sh
──────────────────────────────────────────────────────────────────
EOF

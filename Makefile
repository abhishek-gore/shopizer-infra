.PHONY: help setup build load deploy update clean status logs

IMAGE_TAG ?= latest

help:
	@echo "Shopizer Infrastructure Commands"
	@echo ""
	@echo "  make setup    - Full bootstrap (Colima + build + deploy)"
	@echo "  make build    - Build Docker images"
	@echo "  make load     - Load images into Colima"
	@echo "  make deploy   - Deploy to Kubernetes"
	@echo "  make update   - Rolling update (rebuild + redeploy)"
	@echo "  make clean    - Remove all resources"
	@echo "  make status   - Show infrastructure status"
	@echo "  make logs     - View logs (SERVICE=backend|admin|shop)"
	@echo ""
	@echo "Environment:"
	@echo "  IMAGE_TAG=$(IMAGE_TAG)"

setup:
	./scripts/setup.sh

build:
	IMAGE_TAG=$(IMAGE_TAG) ./scripts/build-images.sh

load:
	IMAGE_TAG=$(IMAGE_TAG) ./scripts/load-images.sh

deploy:
	IMAGE_TAG=$(IMAGE_TAG) ./scripts/deploy.sh

update: build load
	IMAGE_TAG=$(IMAGE_TAG) ./scripts/update-deployment.sh all

clean:
	./scripts/cleanup.sh

status:
	./scripts/status.sh

logs:
	./scripts/logs.sh $(SERVICE)

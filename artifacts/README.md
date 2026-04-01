# Artifacts Directory

This directory contains pre-built artifacts for Shopizer services.

## Contents

- `backend/app.jar` - Backend Spring Boot application (193 MB)
- `admin/dist/` - Admin UI build files (11 MB)
- `shop/build/` - Shop UI build files (32 MB)

## Usage

These artifacts are used by the pre-built Dockerfiles to create images without requiring the source repositories.

Users can simply clone this infra repo and run `./scripts/setup.sh` without needing the source code.

## Updating Artifacts

If you have the source repositories and want to update the artifacts:

```bash
# Build from source
./scripts/build-images.sh

# Extract new artifacts
./scripts/extract-artifacts.sh

# Commit the updated artifacts to git (uses Git LFS)
git add artifacts/
git commit -m "Update artifacts"
git push
```

## Git LFS

Artifacts are stored using Git LFS to handle large files efficiently. Make sure Git LFS is installed:

```bash
brew install git-lfs
git lfs install
git lfs pull
```

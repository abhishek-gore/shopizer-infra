# Local Development Infrastructure

## Environment Variables
- IMAGE_TAG: Docker image tag (default: latest)
- NAMESPACE: Kubernetes namespace (default: shopizer-local)

## Configuration
All services run in `shopizer-local` namespace with local domain routing.

## Database
Backend uses H2 in-memory database by default. For persistent storage, add PostgreSQL/MySQL deployment.

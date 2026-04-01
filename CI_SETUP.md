# CI/CD Setup for Artifact Updates

The three source repositories (shopizer, shopizer-admin, shopizer-shop-reactjs) have been configured to automatically push build artifacts to this infra repository.

## Required GitHub Secret

Each source repository needs a GitHub secret named `INFRA_REPO_TOKEN` with a Personal Access Token (PAT) that has write access to this repository.

### Creating the PAT

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Give it a descriptive name: `Shopizer Infra Artifacts`
4. Select scopes:
   - `repo` (Full control of private repositories)
5. Click "Generate token"
6. Copy the token (you won't see it again)

### Adding the Secret to Each Repository

For each of the three repositories:

1. Go to repository Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Name: `INFRA_REPO_TOKEN`
4. Value: Paste the PAT you created
5. Click "Add secret"

Repeat for:
- `shopizer` (backend)
- `shopizer-admin` (Angular admin UI)
- `shopizer-shop-reactjs` (React shop UI)

## How It Works

When code is pushed to the `main` branch of any source repository:

1. **shopizer (Backend)**
   - Builds the JAR file
   - Pushes to `artifacts/backend/app.jar`

2. **shopizer-admin (Admin UI)**
   - Builds the Angular dist
   - Pushes to `artifacts/admin/dist/`

3. **shopizer-shop-reactjs (Shop UI)**
   - Builds the React app
   - Pushes to `artifacts/shop/build/`

All artifacts are tracked with Git LFS automatically.

## Workflow Jobs Added

Each repository now has a `push-to-infra` job that:
- Checks out this infra repository
- Downloads the build artifacts
- Copies them to the appropriate location
- Commits and pushes using Git LFS

## Testing

After setting up the secret, push a change to any source repository's `main` branch and verify:
1. The CI workflow completes successfully
2. A new commit appears in this infra repository
3. The artifacts are updated in the `artifacts/` directory

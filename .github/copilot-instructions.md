# Copilot Instructions for Home Dev Essentials

## Project Overview
This is a Kubernetes-based home development environment orchestrator that deploys a complete observability and development stack using ArgoCD for GitOps. The project is designed for **home lab environments only** - TLS is disabled and security is relaxed for simplicity.

## Architecture Pattern
The deployment follows a strict sequential order managed by numbered directories in `/deployments/`:
1. **00-helm-repos** - Helm repository setup
2. **01-istio** - Service mesh foundation
3. **02-cert-manager** - Certificate management (self-signed)
4. **03-argocd** - GitOps controller
5. **04-gitea** - Git repository server
6. **05-argo-repo** - Repository initialization
7. **finalize** - Application deployment

## Key Workflow Patterns

### Configuration Management
- Simple key-value configuration in `configuration.yaml` with format: `KEY: value`
- Variables follow `APPLICATIONS.SERVICE.KEY` format (e.g., `APPLICATIONS.GITEA.ADMIN.USERNAME`)
- Template substitution replaces `${KEY}` with values during deployment
- No external dependencies like `yq` - uses native text processing

### Deployment Process
```bash
# Windows: .\deploy.bat
# Linux: ./deploy.sh
```
1. Copies `deployments/`, `secrets/`, and `applications/` to `temp/` directory
2. Performs template variable substitution from `configuration.yaml`
3. Executes numbered files (e.g., `01-*.yaml`, `02-*.ops`) sequentially
4. `.yaml` files → `kubectl apply`, `.sh/.bat` files → direct execution, `.ops` files → line-by-line command execution

### Secret Management Architecture
Uses HashiCorp Vault + Vault Secrets Operator pattern:
- **VaultAuth**: Kubernetes service account authentication
- **VaultStaticSecret**: Maps Vault KV paths to Kubernetes secrets
- Example in `/applications/keycloak/secrets.yaml` - follow this pattern for new services

## Critical Integration Points

### ArgoCD GitOps Flow
- ArgoCD manages `/applications/applications/` directory as "App of Apps" pattern
- Git repository hosted in Gitea at `http://gitea-http.gitea.svc.cluster.local:3000`
- All applications self-manage through ArgoCD project named "infra"

### Service Mesh (Istio)
- All services route through Istio Gateway
- Routes defined in `/applications/*/routes/` directories
- Ambient mode configurable via `APPLICATIONS.ISTIO.AMBIENT` in config

### Observability Stack
- **Prometheus**: Metrics collection and alerting
- **Grafana**: Visualization (embedded in Prometheus stack)
- **Loki**: Log aggregation
- **Tempo**: Distributed tracing
- **Alloy**: Telemetry collection agent

## File Naming Conventions
- **Numbered prefixes**: `01-`, `02-` indicate execution order
- **`.ops` files**: Shell command scripts (platform-agnostic commands)
- **`.bat/.sh` files**: Platform-specific scripts
- **`values.yaml`**: Helm chart overrides (most services use Helm)

## Development Workflow
1. Modify `configuration.yaml` for environment-specific values (use simple `KEY: value` format)
2. Add new services by creating directory in `/applications/`
3. Create ArgoCD Application manifest in `/applications/applications/`
4. For secrets: follow Vault pattern in `/applications/keycloak/secrets.yaml`
5. Test deployment order in `/deployments/` if adding infrastructure

## Common Patterns to Follow
- **Never use HTTPS/TLS** - this is a home lab setup
- **All services expose through Istio Gateway** with custom routes
- **Database storage**: Use NFS StorageClass for persistence
- **Helm values**: Override security settings to disable authentication where possible
- **Namespace isolation**: Each service gets its own namespace, defined in `/applications/namespaces/`
- **Simple dependencies**: Only requires `kubectl` and `helm` - no Docker, yq, or other tools

## Key Files for New Contributors
- `configuration.yaml` - Simple key-value environment configuration
- `deploy.bat` / `deploy.sh` - Platform-specific deployment scripts at root level
- `/applications/applications/` - ArgoCD app definitions
- `/applications/keycloak/` - Complete example with secrets management
- `/deployments/03-argocd/` - Shows infrastructure setup pattern
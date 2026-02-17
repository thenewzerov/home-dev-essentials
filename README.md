# Home Dev Essentials

This is a collection of tools and setup scripts to make setting up a home Kubernetes dev environment as painless as possible.

This project focuses on self-hosted projects, allowing you to keep as much of the development lifecycle within your home network as possible.

I've tried to cover as many of the basics as possible, as well as include some useful tools. Most of what I have included are things I have found myself wanting access to at some point, just to make development simpler. That being said, this is mostly tailored to meet **my** needs. Feel free to fork this repo or make a pull request to make it work for you.

Also, this project does include some AI slop.  Mostly in the setup scripts and docs.  Just a disclaimer.

**Big Disclaimer:**

**DO NOT RUN THIS IN PRODUCTION**

The configs below work for a home environment where you don't really care if you lose data. A lot of the settings below are not appropriate if you are running something that will be public in any way, shape, or form.

I also turn off TLS on EVERYTHING.

## What this README Covers:

- [Quickstart](#quickstart)
  - [Setup Configs](#setup-configs)
  - [Run the Install](#run-the-install)
  - [Finalize Secrets](#finalize-secrets)
- [What's Been Added So Far](#whats-been-added-so-far)
  - [Installed in Kubernetes](#installed-in-kubernetes)
    - [Istio](#istio)
    - [ArgoCD](#argocd)
    - [Prometheus Stack](#prometheus-stack)
    - [Grafana Loki](#grafana-loki)
    - [Grafana Tempo](#grafana-tempo)
    - [Grafana Alloy](#grafana-alloy)
    - [Cert Manager](#cert-manager)
    - [Gateway API](#gateway-api)
    - [Kubernetes Dashboard](#kubernetes-dashboard)
    - [IT-Tools](#it-tools)
    - [telemetrygen](#telemetrygen)
    - [HashiCorp Vault](#hashicorp-vault)
    - [Keycloak](#keycloak)
    - [Argo Workflows](#argo-workflows)
    - [Gitea](#gitea)
    - [Nats](#nats)
    - [PGAdmin](#pgadmin)
    - [Docker Registry UI](#docker-registry-ui)
- [Installation Process](#installation-process)
  - [Prerequisites](#prerequisites)
  - [Preparing For Installation](#preparing-for-installation)
    - [Kubernetes](#kubernetes)
    - [Load Balancing](#load-balancing)
    - [DNS](#dns)
    - [Helm](#helm)
- [How to Use This Repo](#how-to-use-this-repo)
  - [Configurations](#configurations)
  - [Istio Configuration](#istio-configuration)
  - [Deploy the Application](#deploy-the-application)
    - [Windows](#windows)
    - [Linux](#linux)
- [Finalize Install](#finalize-install)
- [Post Install Info](#post-install-info)
  - [DNS Routes to Setup](#dns-routes-to-setup)
- [Individual Tools Details](#individual-tools-details)
  - [Istio](#istio-1)
  - [Cert Manager](#cert-manager-1)
  - [ArgoCD](#argocd-1)
  - [IT-Tools](#it-tools-1)
  - [Grafana](#grafana)
  - [Loki](#loki)
  - [Alloy](#alloy)
  - [Tempo](#tempo)
  - [Prometheus](#prometheus)
  - [Vault](#vault)
  - [Keycloak](#keycloak-1)
  - [NATS](#nats-1)
  - [Telemetrygen](#telemetrygen-1)
  - [Vault Secrets Operator](#vault-secrets-operator)
- [Creating Secrets and Deploying Them With Vault Secrets Operator](#creating-secrets-and-deploying-them-with-vault-secrets-operator)
- [Wishlist for Future Things to Add (or automate)](#wishlist-for-future-things-to-add-or-automate)
- [Development](#development)


## Quickstart

### Setup Configs
Fill out the `configuration.cfg` file with your environment-specific values.

### Run the Install
For Windows:

```bash
.\deploy.bat
```

For Linux:
```bash
./deploy.sh
```

**Template-Only Mode**: If you want to generate the `temp/` directory with all template substitutions without deploying, use the `--template-only` (or `-t`) flag:

```bash
# Windows
.\deploy.bat --template-only

# Linux
./deploy.sh --template-only
```

### Finalize Secrets

See the section on [Creating Vault Secrets](### Creating Secrets and Deploying Them With Vault Secrets Operator)

## What's Been Added So Far

### Installed in Kubernetes

- **Istio**
  - [Istio Documentation](https://istio.io/latest/docs/overview/)
  - Installed in Ambient mode (configurable via `APPLICATIONS.ISTIO.AMBIENT` in `configuration.cfg`)
  - Acts as the service mesh and ingress gateway using Kubernetes Gateway API
- **ArgoCD**
  - [ArgoCD Documentation](https://argo-cd.readthedocs.io/en/stable/)
  - GitOps controller managing all applications
- **Prometheus Stack** (prometheus-community/kube-prometheus-stack)
  - **Prometheus**
    - [Prometheus Documentation](https://prometheus.io/)
  - **Prometheus Node Exporter**
    - [Prometheus Node Exporter Documentation](https://github.com/prometheus/node_exporter)
  - **Kube State Metrics**
    - [Kube State Metrics Documentation](https://github.com/kubernetes/kube-state-metrics)
  - **Grafana**
    - [Grafana Documentation](https://grafana.com/docs/grafana/latest/)
- **Grafana Loki**
    - [Grafana Loki Documentation](https://grafana.com/docs/loki/latest/)
    - Log aggregation
- **Grafana Tempo**
    - [Grafana Tempo Documentation](https://grafana.com/docs/tempo/latest/)
    - Distributed tracing backend
- **Grafana Alloy**
    - [Grafana Alloy Documentation](https://grafana.com/docs/alloy/latest/)
    - Telemetry collection agent
- **Cert Manager**
    - [Cert Manager Documentation](https://cert-manager.io/)
    - Self-signed wildcard certificate management
- **Gateway API**
    - [Gateway API Documentation](https://gateway-api.sigs.k8s.io/)
    - Kubernetes Gateway API for ingress routing with Istio
- **Kubernetes Dashboard**
    - [Kubernetes Dashboard Documentation](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)
    - Web UI for cluster management with custom reverse proxy
- **IT-Tools**
    - [IT-Tools Documentation](https://it-tools.tech/)
    - Collection of handy developer tools
- **telemetrygen**
    - [telemetrygen Documentation](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/cmd/telemetrygen)
    - Sample telemetry generator for testing observability stack
- **HashiCorp Vault**
    - [HashiCorp Vault Documentation](https://developer.hashicorp.com/vault)
    - Secrets management
- **Vault Secrets Operator**
    - [Vault Secrets Operator Documentation](https://developer.hashicorp.com/vault/docs/platform/k8s/vso)
    - Syncs Vault secrets to Kubernetes
- **Keycloak**
    - [Keycloak Documentation](https://www.keycloak.org/)
    - Identity and access management
- **Argo Workflows**
    - [Argo Workflows Documentation](https://argoproj.github.io/workflows/)
    - Workflow orchestration engine
- **Gitea**
    - [Gitea Documentation](https://docs.gitea.io/)
    - Self-hosted Git service with Act Runner for CI/CD
- **NATS**
    - [NATS Documentation](https://nats.io/about/)
    - Message broker with web UI
- **PGAdmin**
    - [PGAdmin Documentation](https://www.pgadmin.org/)
    - PostgreSQL management tool
- **Docker Registry UI**
    - [Docker Registry UI Documentation](https://github.com/Joxit/docker-registry-ui)
    - Web interface for browsing Docker registry


## Instillation Process

## Prerequisites

1. **kubectl** - Installed and connected to your target Kubernetes cluster
2. **Helm** - Installed and configured (pointing to your cluster)
3. **Docker** (optional) - Required only if you want to use the Kubernetes Dashboard reverse proxy. You'll need to build and push the proxy image to your private registry.

## Preparing For Installation

### Kubernetes

This repo assumes you have a Kubernetes cluster setup, and that your kubectl is pointing to that cluster.

### Load Balancing

This setup does not require an external load balancer. The Istio Gateway is configured with NodePort services.

When deploying, a patch operation sets the NodePorts to:
- **30080** - HTTP traffic
- **30443** - HTTPS traffic

Configure your router/firewall to forward ports 80 and 443 to these NodePorts on your cluster node.

### DNS

You MUST have a DNS configuration setup.

Actually, maybe not.  You might be able to do this by using an IP address.
Honestly, I've never tried.  Make a pull request to update this if you try it and it works!

### Helm

Install Helm. [Helm Documentation](https://helm.sh/)


## How to Use This Repo

### Configurations

Edit the `configuration.cfg` file with your environment-specific values. The format is simple key-value pairs:

```
KEY: value
```

Variables use the format `APPLICATIONS.SERVICE.KEY` (e.g., `APPLICATIONS.GITEA.ADMIN.USERNAME`). During deployment, all `${KEY}` placeholders in templates are replaced with these values.

### Istio Configuration

Istio can be configured for MicroK8s and Ambient mode via the configuration file:
- `APPLICATIONS.GLOBAL.MICROK8S: true/false` - Enable MicroK8s-specific settings
- `APPLICATIONS.ISTIO.AMBIENT: true/false` - Enable Istio Ambient mode (sidecar-less service mesh)
- `APPLICATIONS.ISTIO.GLOBAL.PLATFORM: <string>|none` - Sets Helm `--set global.platform=...` for Istio charts (blank/`none` omits the flag; supports any Istio-supported platform value)
- `APPLICATIONS.ISTIO.CNI.CHAINED: true|false|none` - Sets Helm `--set chained=...` for the Istio CNI chart (blank/`none` omits the flag)

### Deploy the Application

#### Windows
```bash
.\deploy.bat
```

#### Linux
```bash
./deploy.sh
```

#### Template-Only Mode
To generate the `temp/` directory without deploying:
```bash
# Windows
.\deploy.bat --template-only

# Linux
./deploy.sh -t
```

**Note**: The initial commit to the Gitea repository sometimes fails. If it does, re-run the finalization script located in `.\temp\deployments\finalize\` (`push-repo.bat` or `push-repo.sh`).


## Finalize Install

Run the commands to setup Vault and create the secrets for Keycloak.

Simplified instructions are here:  [Creating Secrets and Deploying Them With Vault Secrets Operator](#creating-secrets-and-deploying-them-with-vault-secrets-operator)

## Post Install Info

### DNS Routes to Setup

Set up the following DNS routes to point to your cluster's IP (where the Istio Gateway is exposed on ports 30080/30443).

Using `*.example.com` to match the default `configuration.cfg` file. Update to match your `APPLICATIONS.GLOBAL.BASE_URL` setting.

```
alloy.example.com
argocd.example.com
kiali.example.com
grafana.example.com
keycloak.example.com
nats.example.com
prometheus.example.com
tools.example.com
vault.example.com
workflows.example.com
pgadmin.example.com
docker.example.com
gitea.example.com
dashboard.example.com
```

A bookmarks file with all configured URLs is available at `docs/bookmarks.md` after deployment.

## Individual Tools Details

Not everything installed has a section here. This is mostly just capturing what configs are needed.

### Istio

Istio serves as both the service mesh and ingress gateway. It can be installed in ambient mode (sidcar-less) by setting `APPLICATIONS.ISTIO.AMBIENT: true` in `configuration.cfg`.

All namespaces are annotated to be included in the Istio mesh. Ingress routing uses the Kubernetes Gateway API with support for HTTPRoute and TCPRoute resources.

**Gateway Configuration**:
- Standard Gateway API: v1.4.0
- Experimental features enabled (includes TCPRoute)
- NodePorts: 30080 (HTTP), 30443 (HTTPS)

### Cert Manager

`cert-manager` is used to create all our certificates.  These are all self-signed wildcard certs.

### Gateway API

The Kubernetes Gateway API provides ingress routing capabilities through Istio. Both standard and experimental resources are installed:
- HTTPRoute for HTTP/HTTPS routing
- TCPRoute for TCP-based services
- Gateway resource defining the ingress points

All service routes are defined in `/applications/*/routes/` directories and managed by ArgoCD.

### Kubernetes Dashboard

The Kubernetes Dashboard provides a web UI for cluster management. Access is secured through a custom reverse proxy that injects the admin bearer token.

**Setup Requirements**:

1. **Build the reverse proxy image**:
   ```bash
   cd reverse-proxy
   docker build -t registry.${APPLICATIONS.GLOBAL.BASE_URL}/kube-dash-proxy .
   ```

2. **Push to your private registry**:
   ```bash
   docker push registry.${APPLICATIONS.GLOBAL.BASE_URL}/kube-dash-proxy
   ```
   Replace `${APPLICATIONS.GLOBAL.BASE_URL}` with your actual domain from `configuration.cfg`.

3. **Get the admin token**:
   ```bash
   kubectl -n kubernetes-dashboard get secret admin-user -o jsonpath="{.data.token}" | base64 -d
   ```

4. **Access the dashboard**:
   Navigate to `https://dashboard.${APPLICATIONS.GLOBAL.BASE_URL}`

**Local Testing** (optional):
```bash
# Port-forward the dashboard service
kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443

# Run the reverse proxy locally
cd reverse-proxy
docker-compose up -d

# Access at http://localhost:8080
```

### ArgoCD

We install ArgoCD.

To get the default password to login, run this command:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Gitea

Gitea is a self-hosted Git service that hosts the infrastructure repository for ArgoCD.

During deployment:
1. Gitea is installed
2. An `infra` repository is created
3. The `applications/`, `deployments/`, and `secrets/` directories are committed and pushed
4. ArgoCD monitors this repository for GitOps automation

**Act Runner** is included for CI/CD workflows with Docker-in-Docker support.

Access Gitea at `https://gitea.${APPLICATIONS.GLOBAL.BASE_URL}`

Credentials are defined in `configuration.cfg`:
- Username: `APPLICATIONS.GITEA.ADMIN.USERNAME`
- Password: `APPLICATIONS.GITEA.ADMIN.PASSWORD`

### IT-Tools

To access IT-Tools, navigate to https://tools.example.com

### Grafana

To access Grafana, navigate to https://grafana.example.com

Default username is `admin`

To get the password, run the following command

```
kubectl get secret --namespace grafana prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode
```

### Loki

Once Loki has been deployed, you need to connect it to Grafana.

This should already be done for you, but in case something goes wrong and you need to re-connect it:

In Grafana, add a new `Data Source` of type `Loki`.

This is your connection URL:
```
http://loki.loki.svc.cluster.local:3100
```

You will also need to add an HTTP Header.  

They Header is `X-Scope-OrgID`, the value needs to match your `APPLICATIONS.GRAFANA.HEADER_VALUE` config.

After this is completed, you should be able to view the logs through the `Explore` function in Grafana.

### Alloy

Alloy is setup as a logs/metrics/traces collector.  

It should grab all the logs from your pods and make them available in Grafana through Loki. Traces sent to it will be forwarded to Tempo.

### Tempo

Tempo is used to store your traces. The Otlp endpoint is `tempo.tempo.svc.cluster.local:4317`. From here, configure Grafana to pull them.

### Prometheus

Prometheus is deployed as part of the kube-prometheus-stack and automatically scrapes metrics from Kubernetes and Istio.

Access Prometheus at `https://prometheus.${APPLICATIONS.GLOBAL.BASE_URL}`

Service monitors are defined in `/applications/prometheus/monitors/` for custom metric collection.

### Vault

You will need to run through the vault setup. The ui is available at https://vault.example.com

### Keycloak

Keycloak provides identity and access management.

**Important**: Keycloak will fail to start until you configure Vault secrets. See [Creating Secrets and Deploying Them With Vault Secrets Operator](#creating-secrets-and-deploying-them-with-vault-secrets-operator).

Access Keycloak at `https://keycloak.${APPLICATIONS.GLOBAL.BASE_URL}`

Admin credentials are stored in Vault and configured during the Vault setup process.

### NATS

To connect NUI to your nats server:

1. Open the UI
2. Create a new connection
3. Name can be whatever
4. Host is going to be `nats-headless.nats.svc.cluster.local`
5. No auth other settings needed.

### Docker Registry UI

This gives you a UI for browsing your docker images.  The one we deploy is this one:  https://github.com/Joxit/docker-registry-ui

### Telemetrygen

There is a sample telemetry generator app that's installed, mostly to test the observability stuff. Feel free to delete it if you don't want it.


### Vault Secrets Operator

Vault Secrets Operator is installed.

After Vault has been initialized, you can follow the setup instructions here:

https://developer.hashicorp.com/vault/tutorials/kubernetes/vault-secrets-operator#configure-vault


## Creating Secrets and Deploying Them With Vault Secrets Operator

This is how you create the secrets needed for applications, and have them automatically created in Kubernetes with the Vault Secrets Operator.

Keycloak will fail to start until you set this up.  But it also forces you to make the Vault deployment healthy, as it requires you to unlock it.

1. Login to vault.

2. Create a new Authentication Method.
    * Type should be Kubernetes.
    * Being lazy and naming it `kubernetes`
    * Make sure to set the host for the kubernetes api.
        - It's probably okay to use `https://kubernetes.default.svc`

3. Create a `Kubernetes` type secret engine.  Call it `kubernetes`.
    * Go to Configuration
    * Use the `Local Cluster` configuration
    * Create a role in the secrets engine.
    * Select `Generate entire Kubernetes object chain`
    * Name it `vault`
    * Type will be `ClusterRole`
    * Allowed Kubernetes Namespaces set to `*`

4. Create a new `Policy`.  Call it `keycloak`. Add this policy:
    ```
    path "/keycloak/data/*" {
    capabilities = ["read", "list"]
    }
    ```

5. In the `kubernetes` Authentication Method, add a role.
    * Name it `keycloak`
    * Audience should be `vault`
    * Bound service account names, add `keycloak`
    * Bound service account namespaces, add `keycloak`
    * Under the `Tokens` dropdown, scroll down to `Generated Token's Policies`
    * Add `keycloak`.

6. Create a new KV Secrets Engine. We'll use the `keycloak` deployment as an example.  Name the Secrets Engine `keycloak`.

7. Create a new `Secret` inside the `keycloak` secrets engine.
    * Name it `postgres`
    * Add the following secret data to it:
        * POSTGRES_DB
        * POSTGRES_PASSWORD
        * POSTGRES_USER

8. Create a new `Secret` inside the `keycloak` secrets engine.
    * Name it `keycloak-admin`
    * Add the following secret data to it:
        * KC_BOOTSTRAP_ADMIN_PASSWORD
        * KC_BOOTSTRAP_ADMIN_USERNAME
    * These will be your credentials to login to Keycloak.

9. Finally, create your Service Account, VaultAuth, and VaultStaticSecret.
    * See `/applications/keycloak/secrets.yaml` for an example.


### Creating Your Own Secrets
If you want to create additional secrets for different namespaces, begin from step 4.

Change values as appropriate.  For the most part, you can use the `/applications/keycloak/secrets.yaml` file as a template.



## Wishlist for Future Things to Add (or automate)
* Kubernetes Automated Install
    https://kubernetes.io/
* Container Repository
    https://hub.docker.com/_/registry
* Package Registry
    TODO:  Pick one
* Add Cert Manager to Applications.

There's also a few things that still need to be taken care of as part of this project:

* Move as many secrets as possible to Vault.
    * Gitea  
        * That secret is needed before Vault is setup. Bootstrap paradox.
    * PGAdmin
        * Just lazy, didn't want to create a super-long readme.


## Development

Deployment script workflow:

1. **Template Processing**:
   - Creates `temp/` directory
   - Copies `deployments/`, `secrets/`, and `applications/` to `temp/`
   - Reads `configuration.cfg` and replaces all `${KEY}` placeholders with configured values
   - No external dependencies like `yq` - uses native PowerShell/Bash text processing

2. **Sequential Deployment**:
   - Deployment directories are processed in numerical order (00, 01, 02, etc.)
   - Files within each directory are also processed by number

3. **File Type Handling**:
   - `.yaml` files → `kubectl apply`
   - `.ops` files → Line-by-line command execution (platform-agnostic)
   - `.bat` files → Windows batch execution
   - `.sh` files → Linux shell execution

4. **Template-Only Mode**:
   - Use `--template-only` or `-t` flag to generate `temp/` without deploying
   - Useful for verifying template substitutions

**Adding New Services**:
1. Create directory in `/applications/`
2. Add ArgoCD Application manifest in `/applications/applications/`
3. For secrets: follow Vault pattern in `/applications/keycloak/secrets.yaml`
4. For routes: add HTTPRoute/TCPRoute in service's `routes/` subdirectory

**Adding Deployment Steps**:
1. Create numbered file in appropriate `/deployments/` subdirectory
2. Use `.ops` for platform-agnostic commands
3. For platform-specific needs, provide both `.bat` and `.sh` versions
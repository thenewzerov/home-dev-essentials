# Home Dev Essentials

This is a collection of tools and setup scripts to make setting up a home Kubernetes dev environment as painless as possible.

This project focuses on self-hosted projects, allowing you to keep as much of the development lifecycle within your home network as possible.

I've tried to cover as many of the basics as possible, as well as include some useful tools. Most of what I have included are things I have found myself wanting access to at some point, just to make development simpler. That being said, this is mostly tailored to meet **my** needs. Feel free to fork this repo or make a pull request to make it work for you.

**Big Disclaimer:**

**DO NOT RUN THIS IN PRODUCTION**

The configs below work for a home environment where you don't really care if you lose data. A lot of the settings below are not appropriate if you are running something that will be public in any way, shape, or form.

I also turn off TLS on EVERYTHING.

## Template Project

There is also a template project located [here](https://github.com/thenewzerov/home-dev-essentials-template)  that is made to build services that work with this project.

Honestly, I'm not a huge fan of this template project.  But it works.

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
    - [Nginx Ingress](#nginx-ingress)
    - [Cert Manager](#cert-manager)
    - [IT-Tools](#it-tools)
    - [telemetrygen](#telemetrygen)
    - [HashiCorp Vault](#hashicorp-vault)
    - [Keycloak](#keycloak)
    - [Argo Workflows](#argo-workflows)
    - [Nats](#nats)
    - [Nui (NATS GUI)](#nui-nats-gui)
    - [PGAdmin](#pgadmin)
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
Fill out the configuration.yaml

### Run the Install
For Windows:

```
.\windows\deploy.bat
```

For Linux:
```
./linux/deploy.bat
```

### Finalize Secrets

See the section on [Creating Vault Secrets](### Creating Secrets and Deploying Them With Vault Secrets Operator)

## What's Been Added So Far

### Installed in Kubernetes

- **Istio**
  - [Istio Documentation](https://istio.io/latest/docs/overview/)
  - We install Istio in Ambient mode.
- **ArgoCD**
  - [ArgoCD Documentation](https://argo-cd.readthedocs.io/en/stable/)
- **Prometheus Stack from prometheus-community/kube-prometheus-stack**
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
- **Grafana Tempo**
    - [Grafana Tempo Documentation](https://grafana.com/docs/tempo/latest/)
- **Grafana Alloy**
    - [Grafana Alloy Documentation](https://grafana.com/docs/alloy/latest/)
- **Nginx Ingress**
    - [Nginx Documentation](https://www.nginx.com/)
- **Cert Manager**
    - [Cert Manager Documentation](https://cert-manager.io/)
- **IT-Tools**
    - [IT-Tools Documentation](https://it-tools.tech/slugify-string)
- **telemetrygen**
    - [telemetrygen Documentation](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/cmd/telemetrygen)
- **HashiCorp Vault**
    - [HashiCorp Vault Documentation](https://developer.hashicorp.com/vault)
- **Keycloak**
    - [Keycloak Documentation](https://www.keycloak.org/)
- **Argo Workflows**
    - [Argo Workflows Documentation](https://argoproj.github.io/workflows/)
- **Nats**
    - [Nats Documentation](https://nats.io/about/)
- **Nui (NATS GUI)**
    - [Nui Documentation](https://natsnui.app/)
- **PGAdmin**
    - [PGAdmin Documentation](https://www.pgadmin.org/)


## Instillation Process

## Prerequisites

1. Docker is installed on your system. Make sure you can build images locally.
2. Kubectl is installed on your system and connected to your target cluster.
3. Helm is installed and configured correctly (pointing to your cluster in #2)

## Preparing For Installation

### Kubernetes

This repo assumes you have a Kubernetes cluster setup, and that your kubectl is pointing to that cluster.

### Load Balancing

I do NOT assume you have setup a load balancer. Please set one up beforehand.

When deploying the Gateway, we run a patch operation to set the NodePorts.

Your node will have the ports `30080` and `30443` available for ingress traffic.

### DNS

You MUST have a DNS configuration setup.

Actually, maybe not.  You might be able to do this by using an IP address.
Honestly, I've never tried.  Make a pull request to update this if you try it and it works!

### Helm

Install Helm. [Helm Documentation](https://helm.sh/)


## How to Use This Repo

### Configurations

Add your values in the `configuration.yaml` file. Replace all the existing values with your own.

### Istio Configuration

I have this setup to deploy with Microk8s.  There's a config for the Istio CNI install you might need to change if you're not using MicroK8s.


In the `deployments/01-deploy.ops` file, change the lines to remove the following flag:
```bash
--set global.platform=microk8s
```

UPDATE:  I've added configs for Microk8s and Istio Ambient mode in the configuration.yaml file.  No need to do this anymore.  Hopefully.

### Deploy the Application

#### Windows
```
./windows/deploy.bat
```

#### Linux
```
./linux/deploy.sh
```

The commit to the `gitea` repo seems to be 50/50 on if it works.
If it fails, run the commit again.

There's a script to do this in `.\temp\deployments\finalize\` folder.

Execute either `push-repo.bat` or `push-repo.sh`.


## Finalize Install

Run the commands to setup Vault and create the secrets for Keycloak.

Simplified instructions are here:  [Creating Secrets and Deploying Them With Vault Secrets Operator](#creating-secrets-and-deploying-them-with-vault-secrets-operator)

## Post Install Info

### DNS Routes to Setup

Set up the following DNS routes to point to your proxy. Or load balancer. Whatever you have setup.

I'm using `*.example.com` to match the default configuration.yaml file. Update to match your configuration.

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
```

There's a file that's generated in the `deployments\21-bookmarks` folder that will have links to all the sites, with your configured urls.

## Individual Tools Details

Not everything installed has a section here. This is mostly just capturing what configs are needed.

### Istio

Istio is optionally installed in ambient mode, that way I don't have to deal with sidecars. This is mostly just to try out the ambient mode features.

I include the annotations to add all the created namespaces to Istio (unless otherwised noted).

This is also our Gateway.  We're using the new Kubernetes Gateway API to handle ingress traffic, and allowing Istio to do it's thing.

I've enabled the use to `TCPRoute` from the Kubernetes Gateway API as part of the install.

### Cert Manager

`cert-manager` is used to create all our certificates.  These are all self-signed wildcard certs.

### ArgoCD

We install ArgoCD.

To get the default password to login, run this command:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Gitea and Act Runner

To work with ArgoCD, Gitea is installed.  The initial repo for this project is created and pushed up to the Gitea instance.

As part of this, Gitea's Act Runner has been installed and configured for Docker in Docker as well.


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

TODO: Check the configuration on this one. Might not be pulling correctly? Need to deploy a REAL test app.

### Vault

You will need to run through the vault setup. The ui is available at https://vault.example.com

### Keycloak

The username/password are set in the `configuration.yaml` file

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

3. Create a `Kubernetes` type secret engine.  Call it `kubernetes`.
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
    * Add `keycloak-postgres`.  We'll set this up later.

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

If you can't understand what the scripts are doing for the deployment, here's a simple breakdown.

1. When first run, a linux container with `yq` and `kubectl` is built and tagged as `home-dev-essentials`. This is used to configure the yaml files.

2. A new directory is created `/temp`.

3. All the deployment files are copied to this directory.
    * As the files are copied over, any values with the format ${KEY} are replaced with the value from `configuration.yaml`

4. The different deployment directories are run through in numerical order.

5. Each file in each deployment directory is checked.
    * If the file begins with a number and a `-` it's installed.
    * `.yaml` files are run with a `kubectl apply`
    * `.bat` and `.sh` files are run (depending on which deploy script you're running)

New deployments (or new steps) can be added by creating a new file with the appropriate number.

If you make a merge request, make sure you include both a `.sh` and a `.bat` file for anything being added.
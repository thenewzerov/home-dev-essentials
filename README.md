# Home Dev Essentials

This is a collection of tools and setup scripts to make setting up a home Kubernetes dev environment as painless as possible.

This project focuses on self-hosted projects, allowing you to keep as much of the development lifecycle within your home network as possible.

I've tried to cover as many of the basics as possible, as well as include some useful tools. Most of what I have included are things I have found myself wanting access to at some point, just to make development simpler. That being said, this is mostly tailored to meet **my** needs. Feel free to fork this repo or make a pull request to make it work for you.

**Big Disclaimer:**

**DO NOT RUN THIS IN PRODUCTION**

The configs below work for a home environment where you don't really care if you lose data. A lot of the settings below are not appropriate if you are running something that will be public in any way, shape, or form.

I also turn off TLS on EVERYTHING.

## What this README Covers:

- [Quickstart](#quickstart)
- [What's Been Added So Far](#whats-been-added-so-far)
  - [Installed in Kubernetes](#installed-in-kubernetes)
    - [Istio](#istio)
    - [ArgoCD](#argocd)
    - [Prometheus Stack](#prometheus-stack)
      - [Prometheus](#prometheus)
      - [Prometheus Node Exporter](#prometheus-node-exporter)
      - [Kube State Metrics](#kube-state-metrics)
      - [Grafana](#grafana)
    - [Grafana Loki](#grafana-loki)
    - [Grafana Tempo](#grafana-tempo)
    - [Grafana Alloy](#grafana-alloy)
    - [Nginx Ingress](#nginx-ingress)
    - [Cert Manager](#cert-manager)
    - [IT-Tools](#it-tools)
    - [telemetrygen](#telemetrygen)
    - [HashiCorp Vault](#hashicorp-vault)
    - [Keycloak](#keycloak)
    - [OpenProject](#openproject)
    - [Argo Workflows](#argo-workflows)
    - [Nats](#nats)
    - [Nui (NATS GUI)](#nui-nats-gui)


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

Run the command found in the `\temp\secrets\keycloak.ops` file.

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
- **OpenProject**
    - [OpenProject Documentation](https://www.openproject.org/)
- **Argo Workflows**
    - [Argo Workflows Documentation](https://argoproj.github.io/workflows/)
- **Nats**
    - [Nats Documentation](https://nats.io/about/)
- **Nui (NATS GUI)**
    - [Nui Documentation](https://natsnui.app/)


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

### Deploy the Application

#### Windows
```
./windows/deploy.bat
```

#### Linux
```
./linux/deploy.bat
```

The commit to the `gitea` repo seems to be 50/50 on if it works.
If it fails, run the commit again.

There's a script to do this in `.\temp\deployments\finalize\` folder.

Execute either `push-repo.bat` or `push-repo.sh`.


## Finalize Install

Run the command found in the generated file at `\temp\secrets\keycloak.ops`.

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
openproject.example.com
prometheus.example.com
tools.example.com
vault.example.com
workflows.example.com
```

There's a file that's generated in the `deployments\21-bookmarks` folder that will have links to all the sites, with your configured urls.

## Individual Tools Details

Not everything installed has a section here. This is mostly just capturing what configs are needed.

### Istio

Istio is installed in ambient mode, that way I don't have to deal with sidecars. This is mostly just to try out the ambient mode features.

I include the annotations to add all the created namespaces to Istio (unless otherwised noted).

This is also our Gateway.  We're using the new Kubernetes Gateway API to handle ingress traffic, and allowing Istio to do it's thing.

### Cert Manager

`cert-manager` is used to create all our certificates.  These are all self-signed wildcard certs.

### ArgoCD

We install ArgoCD.

To get the default password to login, run this command:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

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

In Grafana, add a new `Data Source` of type `Loki`.

This is your connection URL:
```
http://loki-gateway.loki.svc.cluster.local
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

### Openproject

When loading, will have the default username/password. Will need to be reset when you first login.

### Telemetrygen

There is a sample telemetry generator app that's installed, mostly to test the observability stuff. Feel free to delete it if you don't want it.

## Wishlist for Future Things to Add (or automate)
* Gitlab (with runners?)
    https://about.gitlab.com/install/
* Drone CI (if not using gitlab runners)
	https://www.drone.io/
* Kubernetes
    https://kubernetes.io/
* Container Repository
    https://hub.docker.com/_/registry
* Container Registry UI
    https://github.com/Joxit/docker-registry-ui
* Package Registry
    TODO:  Pick one

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
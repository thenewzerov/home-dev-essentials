# Home Dev Essentials

This is a collection of tools and setup scripts to make setting up a home Kubernetes dev environment as painless as possible.

This project focuses on self-hosted projects, allowing you to keep as much of the development lifecycle within your home network as possible.

I've tried to cover as many of the basics as possible, as well as include some useful tools. Most of what I have included are things I have found myself wanting access to at some point, just to make development simpler. That being said, this is mostly tailored to meet **my** needs. Feel free to fork this repo or make a pull request to make it work for you.

**Big Disclaimer:**

**DO NOT RUN THIS IN PRODUCTION**

The configs below work for a home environment where you don't really care if you lose data. A lot of the settings below are not appropriate if you are running something that will be public in any way, shape, or form.

## What this README Covers:

- [What's Been Added So Far](#whats-been-added-so-far)
  - [Installed in Kubernetes](#installed-in-kubernetes)
    - [Istio](#istio)
    - [Kubernetes Dashboard](#kubernetes-dashboard)
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

## What's Been Added So Far

### Installed in Kubernetes

- **Istio**
  - [Istio Documentation](https://istio.io/latest/docs/overview/)
  - We install Istio in Ambient mode.
- **Kubernetes Dashboard**
  - [Kubernetes Dashboard Documentation](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)
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

## Prerequisites

1. Docker is installed on your system. Make sure you can build images locally.
2. Kubectl is installed on your system and connected to your target cluster.
3. Helm is installed and configured correctly (pointing to your cluster in #2)

## How to Use This Repo

### Configurations

Add your values in the `configuration.yaml` file. Replace all the existing values with your own.

### Istio Configuration

I have this setup to deploy with Microk8s.  There's a config for the Istio CNI install you might need to change if you're not using MicroK8s.


In the `deployments/01-deploy.bat` and `deployments/01-deploy.sh` files, change this line:
```bash
helm upgrade --install istio-cni istio/cni -n istio-system --set profile=ambient --set global.platform=microk8s --wait
```

and remove the `global.platform flag.

```bash
helm upgrade --install istio-cni istio/cni -n istio-system --set profile=ambient --wait
```

### Istio Metrics

Still haven't managed to get Istio metrics working.  Or not all of them, with Ambient mode.  If anyone knows what's going on, any help would be appreciated!


### Windows
```
./windows/deploy.bat
```

### Linux
```
./linux/deploy.bat
```

## Preparing For Installation

### Kubernetes

This repo assumes you have a Kubernetes cluster setup, and that your kubectl is pointing to that cluster. I am running MicroK8s.

### Load Balancing / DNS

I do NOT assume you have setup a load balancer. Please set one up beforehand.

I run Pi-hole and HAProxy with a Layer 4 proxy to MicroK8s. The setup commands for that are below.

### Helm

Install Helm. [Helm Documentation](https://helm.sh/)

## Post Install Info

### DNS Routes to Setup

Set up the following DNS routes to point to your proxy. Or load balancer. Whatever you have setup.

I'm using `*.example.com` to match the default configuration.yaml file. Update to match your configuration.

```
alloy.example.com
argo.example.com
kiali.example.com
dashboard.example.com
grafana.example.com
keycloak.example.com
nats.example.com
openproject.example.com
prometheus.example.com
tools.example.com
vault.example.com
```

There's a file that's generated in the `deployments\21-bookmarks` folder that will have links to all the sites, with your configured urls.

## Individual Tools Details

Not everything installed has a section here. This is mostly just capturing what configs are needed.

### Istio

Istio is installed in ambient mode, that way I don't have to deal with sidecars. This is mostly just to try out the ambient mode features.

### Dashboard

To access the dashboard, navigate to https://dashboard.example.com

To login, run the following command to get a token:

```
kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d
```

If running on Windows, run the following command, then copy the values from the `token` field and base64 decode it using the tools link above.

```
kubectl get secret admin-user -n kubernetes-dashboard -o yaml
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
* Argo CD
	https://argo-cd.readthedocs.io/en/stable/
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
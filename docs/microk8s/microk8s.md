## Running with MicroK8s

Because there's a bunch of stuff I'm going to forget if I don't write it down, here's how to set up UFW to allow MicroK8s forwarding for the Istio Gateway.

## Reset MicroK8s

You can reset MicroK8s to a clean version with the following command:

```bash
sudo microk8s reset
```

## Install and Configure MicroK8s

These commands will install MicroK8s and install some of the addons used by this repo.

```bash
sudo snap install microk8s --classic
microk8s enable dns
microk8s enable hostpath-storage
```
## Setting Up Remote Access

I'm assuming you know how to open the ports needed for remotely accessing your cluster.

To copy your config from MicroK8s to your standard kube config file:
```bash
microk8s config > ~/.kube/config
```

### Edit the UFW config files to allow forwarding

If `UFW` is not running by default, you may have to enable it before you run the following steps.
```bash
sudo ufw enable
```

The Istio Gateway is configured with fixed NodePorts (30080 for HTTP, 30443 for HTTPS).

You can verify the ports with:
```bash
kubectl get service -n istio-system infra-gateway-istio
```

Allow forwarding in UFW:
```bash
sudo ufw allow 80     # HTTP Traffic
sudo ufw allow 443    # HTTPS Traffic
sudo ufw allow 30080  # Istio Gateway HTTP NodePort
sudo ufw allow 30443  # Istio Gateway HTTPS NodePort
sudo ufw allow 6443   # Kubernetes API Server
```


Finally, restart UFW
```bash
sudo ufw disable && sudo ufw enable
```

## Reverse Proxy Setup

If you need a reverse proxy to map standard ports 80/443 to the Istio Gateway NodePorts (30080/30443), see:

- [HAProxy Setup](haproxy-setup.md) - For HAProxy configuration
- [Nginx Proxy Setup](nginx-proxy-setup.md) - For Nginx configuration

## Other Add-ons

Some of the other features you might want to setup with Microk8s, or at least look into:

* helm
* registry

Honestly, there's a ton.  A lot of the really good ones I'm already taking care of for you (dashboard, argocd, etc...)
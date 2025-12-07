# Setting Up K3S for a Homelab

Mostly we're just going to follow the `k3s` setup.  But there's a couple things we should do first


## Setup for Longhorn

Make sure this stuff is setup on the hosts first:

```
sudo apt-get install -y open-iscsi nfs-common util-linux
```

## Private Registry
When creating your cluster, you probably want to have your own private registry.

On all the machines, you'll need to add an entry such as this to `/etc/rancer/k3s/registries.yaml`:

```
mirrors:
  "registry.yourdomain.com":
    endpoint:
      - "http://registry.yourdomain.com:5000"
configs:
  "registry.yourdomain.com":
    tls:
      insecure_skip_verify: true
```

Since I didn't figure this out until AFTER I had deployed everything, I need to see if there's a way to include this during setup.

After adding this, on any controller nodes run:

`sudo systemctl restart k3s`

On any worker/agent nodes run:

`sudo systemctl restart k3s-agent`



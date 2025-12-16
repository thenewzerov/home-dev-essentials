# Watchers in Ubuntu

Kubernetes relies heavily on a Linux feature called inotify to track changes to files (logs, secrets, configmaps). Every time you deploy a pod, you consume these watchers.

* K3s uses them.
* Longhorn (which you use) uses a ton of them.
* ArgoCD uses them.

Sometimes, you'll see error messages on your server, or in your logs with a line like "too many open files".

This is because of a default setting in some Linux distro's.  Looking at you Ubuntu!

## The Fix
You need to increase the kernel limits for file watchers on your Node (the actual Linux OS hosting K3s).

### Step 1 - Apply the Immediate Fix (No Reboot)
Run these commands on your K3s server(s):

```Bash

# Check current limits (likely 8192 or 128)
sysctl fs.inotify.max_user_watches
sysctl fs.inotify.max_user_instances

# Bump them way up
sudo sysctl -w fs.inotify.max_user_watches=61232
sudo sysctl -w fs.inotify.max_user_instances=128
```

### Step 2 - Make it Permanent 
If you don't do this, it will break again when you reboot. Edit /etc/sysctl.conf:

```Bash
sudo nano /etc/sysctl.conf
```

Add these lines to the bottom:

```Ini, TOML

fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 8192
```
Save and exit. Then reload:

```Bash
sudo sysctl -p
```
# HAProxy Reverse Proxy Setup

[HAProxy](https://www.haproxy.org/) can be used as a reverse proxy to map standard ports 80/443 to the Istio Gateway NodePorts (30080/30443).

## Installation

Install HAProxy on your server:

```bash
sudo apt-get install haproxy
```

## Configuration

Edit the HAProxy config file at `/etc/haproxy/haproxy.cfg` with the configuration below.

**Note**: The backend ports (30080 and 30443) are the Istio Gateway NodePorts configured in this project.

```
global
	log /dev/log	local0
	log /dev/log	local1 notice
	chroot /var/lib/haproxy
	stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
	stats timeout 30s
	user haproxy
	group haproxy
	daemon

	# Default SSL material locations
	ca-base /etc/ssl/certs
	crt-base /etc/ssl/private

	# See: https://ssl-config.mozilla.org/#server=haproxy&server-version=2.0.3&config=intermediate
        ssl-default-bind-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
        ssl-default-bind-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256
        ssl-default-bind-options ssl-min-ver TLSv1.2 no-tls-tickets

defaults
	log	global
	mode	tcp
	option	tcplog
	option	dontlognull
        timeout connect 5000
        timeout client  50000
        timeout server  50000
	errorfile 400 /etc/haproxy/errors/400.http
	errorfile 403 /etc/haproxy/errors/403.http
	errorfile 408 /etc/haproxy/errors/408.http
	errorfile 500 /etc/haproxy/errors/500.http
	errorfile 502 /etc/haproxy/errors/502.http
	errorfile 503 /etc/haproxy/errors/503.http
	errorfile 504 /etc/haproxy/errors/504.http

frontend samplehttp 
	bind :80
	default_backend insecure-backend

backend insecure-backend
	server k8slocalhttp localhost:30080

frontend samplehttps
	bind :443
	default_backend secure-backend

backend secure-backend
	server k8slocalhttps localhost:30443
```

## Restart HAProxy

After updating the configuration, restart HAProxy:

```bash
sudo service haproxy restart
```

## Verify

Test that traffic is being forwarded correctly:

```bash
# Check HAProxy status
sudo systemctl status haproxy

# Test HTTP (should reach your Istio Gateway)
curl http://localhost

# Check HAProxy stats socket
echo "show info" | sudo socat stdio /run/haproxy/admin.sock
```

## Load Balancing Multiple Nodes

If you have multiple Kubernetes nodes, you can configure HAProxy to load balance across them:

```
backend insecure-backend
	balance roundrobin
	server k8snode1 192.168.1.10:30080 check
	server k8snode2 192.168.1.11:30080 check
	server k8snode3 192.168.1.12:30080 check

backend secure-backend
	balance roundrobin
	server k8snode1 192.168.1.10:30443 check
	server k8snode2 192.168.1.11:30443 check
	server k8snode3 192.168.1.12:30443 check
```

Replace the IP addresses with your actual Kubernetes node IPs.

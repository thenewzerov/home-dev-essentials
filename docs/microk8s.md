## Running with Microk8s

Because there's a bunch of stuff I'm going to forget if I don't write it down, here's how to setup UFW to allow Microk8s forwarding and HAProxy.


### Edit the UFW config files to allow forwarding

You'll have to do this step AFTER you have the Ingress installed to get the ports.

If `UFW` is not running by default, you may have to enable it before you run the following steps.
```
sudo ufw enable
```

Get the nodePorts from the ingress.
```
kubectl get service -n ingress-nginx ingress-nginx-controller
NAME                       TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-controller   NodePort   192.168.1.107   <none>        80:31824/TCP,443:30478/TCP   22h
```


You will need to allow forwarding in UFW.
```
sudo ufw allow 80     # HTTP Traffic
sudo ufw allow 443    # HTTPS Traffic
sudo ufw allow 31824  # HTTP Nodeport from above
sudo ufw allow 30478  # HTTPS Nodeport from above
sudo ufw allow 6443   # Kubernetes API Server
```


Finally, restart UFW
```
sudo ufw disable && sudo ufw enable
```

### HAProxy

https://www.haproxy.org/

If you need a proxy (to make DNS easy using the correct ports), you can install with HAProxy.  If you have a better way to do this, please let me know!

Install haproxy

```
sudo apt-get install haproxy
```

Edit the config file `/etc/haproxy/haproxy.cfg ` with the values below

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

frontend therackhttp 
	bind :80
	default_backend insecure-backend

backend insecure-backend
	server k8slocalhttp localhost:31824

frontend therackhttps
	bind :443
	default_backend secure-backend

backend secure-backend
	server k8slocalhttps localhost:30478
```

Finally, restart HAProxy
```
sudo service haproxy restart
```

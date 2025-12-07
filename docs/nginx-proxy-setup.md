# Nginx Reverse Proxy Setup

Nginx can be used as a reverse proxy to forward traffic from standard ports 80/443 to the Istio Gateway NodePorts (30080/30443).

## Installation

Install Nginx on your server:

```bash
sudo apt-get update
sudo apt-get install nginx
```

## Configuration

This project includes a sample Nginx configuration file that demonstrates TCP stream proxying to the Istio Gateway NodePorts.

See the sample configuration: [nginx.conf](../nginx.conf)

### Using the Sample Configuration

1. **Review the sample configuration** at the root of this repository: `nginx.conf`

2. **Update the upstream server IPs**:
   ```nginx
   upstream kubernetes_http {
       server 192.168.1.10:30080;  # Replace with your node IP
       server 192.168.1.11:30080;  # Add multiple nodes for HA
       server 192.168.1.12:30080;
   }

   upstream kubernetes_https {
       server 192.168.1.10:30443;  # Replace with your node IP
       server 192.168.1.11:30443;  # Add multiple nodes for HA
       server 192.168.1.12:30443;
   }
   ```

3. **Copy the configuration** to Nginx:
   ```bash
   sudo cp nginx.conf /etc/nginx/nginx.conf
   ```

4. **Verify the configuration**:
   ```bash
   sudo nginx -t
   ```

5. **Restart Nginx**:
   ```bash
   sudo systemctl restart nginx
   ```

## Configuration Breakdown

The sample `nginx.conf` uses the **stream module** for TCP/UDP load balancing:

```nginx
stream {
    upstream kubernetes_http {
        server <server_ip>:30080;
    }

    upstream kubernetes_https {
        server <server_ip>:30443;
    }

    server {
        listen 80;
        proxy_pass kubernetes_http;
    }

    server {
        listen 443;
        proxy_pass kubernetes_https;
    }
}
```

### Key Points:

- **Stream module**: Required for TCP proxying (not HTTP-level proxying)
- **Upstream blocks**: Define backend servers (your Kubernetes nodes with Istio Gateway)
- **Port 80**: Forwards to NodePort 30080 (HTTP)
- **Port 443**: Forwards to NodePort 30443 (HTTPS)

## Verify

Test that traffic is being forwarded:

```bash
# Check Nginx status
sudo systemctl status nginx

# Test HTTP connection
curl http://localhost

# Check Nginx error logs if issues occur
sudo tail -f /var/log/nginx/error.log
```

## High Availability Setup

For HA, list multiple Kubernetes nodes in each upstream block. Nginx will automatically load balance:

```nginx
upstream kubernetes_http {
    server 192.168.1.10:30080;
    server 192.168.1.11:30080;
    server 192.168.1.12:30080;
}

upstream kubernetes_https {
    server 192.168.1.10:30443;
    server 192.168.1.11:30443;
    server 192.168.1.12:30443;
}
```

If a node goes down, Nginx automatically routes to healthy nodes.

## Advanced Options

### Health Checks

Add health check parameters:

```nginx
upstream kubernetes_http {
    server 192.168.1.10:30080 max_fails=3 fail_timeout=30s;
    server 192.168.1.11:30080 max_fails=3 fail_timeout=30s;
}
```

### Load Balancing Methods

Change the load balancing algorithm:

```nginx
upstream kubernetes_http {
    least_conn;  # Route to server with least connections
    server 192.168.1.10:30080;
    server 192.168.1.11:30080;
}
```

Available methods:
- `round_robin` (default)
- `least_conn`
- `ip_hash`
- `hash`

## Troubleshooting

### Stream module not found

If you get an error about the stream module, ensure it's loaded:

```nginx
load_module modules/ngx_stream_module.so;
```

This should be at the top of your `nginx.conf` (already included in the sample).

### Port already in use

If ports 80/443 are already in use:

```bash
# Check what's using the port
sudo netstat -tlnp | grep ':80'

# Stop conflicting service (example for Apache)
sudo systemctl stop apache2
sudo systemctl disable apache2
```

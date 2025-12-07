# Reverse Proxy Docker Container

This reverse proxy container forwards all requests to `host.docker.internal:8443` and automatically adds the authorization header `abc123` to every request.

## Quick Start

1. Build and run the container:
```bash
docker-compose up -d
```

2. The proxy will be available at `http://localhost:8080`

## Manual Build

If you prefer to build and run manually:

```bash
# Build the image
docker build -t reverse-proxy .

# Run the container
docker run -d -p 8080:80 --name reverse-proxy reverse-proxy
```

Made to work with this:
```
kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443
```

## Configuration

- **Target**: `host.docker.internal:8443` (HTTPS)
- **Authorization Header**: `Authorization: abc123`
- **Listen Port**: 80 (mapped to 8080 on host)
- **SSL Verification**: Disabled (for self-signed certificates)

## Files

- `Dockerfile` - Container definition using nginx:alpine
- `nginx.conf` - Nginx configuration with proxy settings
- `docker-compose.yml` - Docker Compose for easy deployment

## Usage

Once running, any request to `http://localhost:8080` will be:
1. Forwarded to `https://host.docker.internal:8443`
2. Include the `Authorization: abc123` header automatically
3. Return the response from the target server
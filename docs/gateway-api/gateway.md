# Gateway API

I've just decided to move immediately to the Gateway API from Kubernetes-Sigs.

https://gateway-api.sigs.k8s.io/

Here's the quick and dirty basics.

## Shared Gateway

I create a common gateway as part of the Cert Manager deployment.  
The reason it's part of the Cert Manager deployment is because it uses the wildcard certs.

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: infra-gateway
  namespace: istio-system
  annotations:
    networking.istio.io/service-type: "NodePort"
    cert-manager.io/cluster-issuer: "ca-issuer"
spec:
  gatewayClassName: istio
  listeners:
    - name: https
      protocol: HTTPS
      port: 443
      allowedRoutes:
        namespaces:
          from: All
      hostname: "*.my-domain.com"
      tls:
        mode: Terminate
        certificateRefs:
          - kind: Secret
            name: infra-wildcard-tls
```

I also patch it to use set ports (makes re-creating the cluster a lot easier, cause I don't have to mess with my load balancer):

```yaml
spec:
  ports:
  - appProtocol: tcp
    name: status-port
    nodePort: 30080
    port: 15021
  - appProtocol: https
    name: https
    nodePort: 30443
    port: 443
```


## Getting Traffic In

When you want traffic to come into the mesh, create a Route.  This should reference the shared gateway:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: argocd
  namespace: argocd
spec:
  parentRefs:
    - name: infra-gateway
      namespace: istio-system
  hostnames:
    - argocd.my-domain.com
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /
      backendRefs:
        - name: argocd-server
          port: 443
```

## TCP Routes

On the off chance you need to do something not http, you create a TCPRoute:

```yaml
apiVersion: gateway.networking.k8s.io/v1alpha2
kind: TCPRoute
metadata:
  name: neo4j-bolt
  namespace: neo4j
spec:
  parentRefs:
    - name: infra-gateway
      namespace: istio-system
      sectionName: neo4j-bolt
  hostnames:
    - neo4j.my-domain.com
  rules:
    - backendRefs:
        - name: neo4j
          port: 7687
```

## Other Stupid Gotchas

If you need to have a cert in another namespace, but need the Gateway to reference it, you need one of these:

```yaml
apiVersion: gateway.networking.k8s.io/v1beta1
kind: ReferenceGrant
metadata:
  name: allow-istio-to-read-certs
  namespace: my-other-cert-namespace  # <--- MUST be in the same namespace as the Secret
spec:
  from:
  - group: gateway.networking.k8s.io
    kind: Gateway
    namespace: istio-system # <--- The namespace of your Gateway
  to:
  - group: ""
    kind: Secret
    # You can optionally restrict by name if you want to be specific:
    # name: neo4j-bolt-tls
```
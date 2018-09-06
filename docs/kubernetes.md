# Kubernetes

Haiku currently doesn't use Kubernetes due to the high learning curve and our
limited sysadmin team resources. Instead we opted for a simpler docker-compose
deployment.

In case you're interested though, here is a configuration
of 32 loadbalanced nginx containers serving a directory from a single-node
kubernetes cluster. A pre-configured ingress controller is assumed. Requests
are filled when the domain is *.k8s (configured via a local host file)


```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: static-www
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 32
  template:
    metadata:
      labels:
        app: nginx
    spec:
      volumes:
      - name: default-web-assets
        hostPath:
          path: /tmp/k8s-volumes
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
        volumeMounts:
          - name: default-web-assets
            mountPath: /usr/share/nginx/html
---
apiVersion: v1
kind: Service
metadata:
  name: static-www
spec:
  ports:
    - name: http
      port: 80
      targetPort: 80
  selector:
    app: nginx
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: static-www
  annotations:
    kubernetes.io/ingress.class: traefik
spec:
  rules:
  - host: "*.k8s"
    http:
      paths:
      - path: /
        backend:
          serviceName: static-www
          servicePort: http
```
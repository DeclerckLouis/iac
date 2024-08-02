# Advanced gateway API usage
TO check if we can proceed, ensure CRDs are installed  
```bash
kubectl get crd \
  gatewayclasses.gateway.networking.k8s.io \
  gateways.gateway.networking.k8s.io \
  httproutes.gateway.networking.k8s.io \
  referencegrants.gateway.networking.k8s.io \
  tlsroutes.gateway.networking.k8s.io \
  grpcroutes.gateway.networking.k8s.io
```

Check the config if gateway API is enabled  
```bash
cilium config view | grep -w "enable-gateway-api "
```

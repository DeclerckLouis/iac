# init
## Table of Contents
- [init](#init)
  - [Table of Contents](#table-of-contents)
  - [Checks](#checks)
    - [How was cilium installed?](#how-was-cilium-installed)

## Checks
Check if the installed CRDs are available
<u><b>Command:</b></u>
```bash
kubectl get crd \
  gatewayclasses.gateway.networking.k8s.io \
  gateways.gateway.networking.k8s.io \
  grpcroutes.gateway.networking.k8s.io \
  httproutes.gateway.networking.k8s.io \
  referencegrants.gateway.networking.k8s.io \
  tlsroutes.gateway.networking.k8s.io```
```

<u><small>output:</small></u>
```bash
NAME                                        CREATED AT
gatewayclasses.gateway.networking.k8s.io    2024-07-16T09:48:37Z
gateways.gateway.networking.k8s.io          2024-07-16T09:48:37Z
httproutes.gateway.networking.k8s.io        2024-07-16T09:48:38Z
referencegrants.gateway.networking.k8s.io   2024-07-16T09:48:38Z
tlsroutes.gateway.networking.k8s.io         2024-07-16T09:48:38Z
Error from server (NotFound): customresourcedefinitions.apiextensions.k8s.io "grpcroutes.gateway.networking.k8s.io" not found
```

### How was cilium installed?
Cilium was installed using the following command:
<u><b>Command:</b></u>
```bash
cilium install --version 1.15.4 \
  --namespace kube-system \
  --set kubeProxyReplacement=true \
  --set gatewayAPI.enabled=true \
```

It's possible to check on the status of cilium like so:
<u><b>Command:</b></u>
```bash
cilium status --wait
```

<u></u><small>Output:</small></u>
```bash
    /¯¯\
 /¯¯\__/¯¯\    Cilium:             OK
 \__/¯¯\__/    Operator:           OK
 /¯¯\__/¯¯\    Envoy DaemonSet:    disabled (using embedded mode)
 \__/¯¯\__/    Hubble Relay:       disabled
    \__/       ClusterMesh:        disabled

Deployment             cilium-operator    Desired: 1, Ready: 1/1, Available: 1/1
DaemonSet              cilium             Desired: 3, Ready: 3/3, Available: 3/3
Containers:            cilium             Running: 3
                       cilium-operator    Running: 1
Cluster Pods:          3/3 managed by Cilium
Helm chart version:    
Image versions         cilium             quay.io/cilium/cilium:v1.14.3@sha256:e5ca22526e01469f8d10c14e2339a82a13ad70d9a359b879024715540eef4ace: 3
                       cilium-operator    quay.io/cilium/operator-generic:v1.14.3@sha256:c9613277b72103ed36e9c0d16b9a17cafd507461d59340e432e3e9c23468b5e2: 1
```

To check if the Gateway API feature was enabled and deployed:
<u><b>Command:</b></u>
```bash
cilium config view | grep -w "enable-gateway-api"
```

<u><small>Output:</small></u>
```bash
enable-gateway-api                                true
enable-gateway-api-secrets-sync                   true
```

Verify that a GatewayClass has been deployed and accepted:
<u><b>Command:</b></u>
```bash
kubectl get gatewayclass
```

<u><small>Output:</small></u>
```bash
NAME     CONTROLLER                     ACCEPTED   AGE
cilium   io.cilium/gateway-controller   True       16m
```

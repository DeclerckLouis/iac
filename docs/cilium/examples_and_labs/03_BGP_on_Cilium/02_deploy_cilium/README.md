# Deploying Cilium
## Table of Contents
- [Deploying Cilium](#deploying-cilium)
  - [Table of Contents](#table-of-contents)
  - [Deploying Cilium](#deploying-cilium-1)

## Deploying Cilium
The cilium installation command looks like this:  
<u><b>Command:</b></u>
```bash
cilium install \
    --version 1.15.0 \
    --set ipam.mode=kubernetes \
    --set tunnel=disabled \
    --set ipv4NativeRoutingCIDR="10.0.0.0/8" \
    --set bgpControlPlane.enabled=true \
    --set k8s.requireIPv4PodCIDR=true
```
We can see here that bgpControlPlane is enabled.  
<u><small>Output:</small></u>
```
🔮 Auto-detected Kubernetes kind: kind
✨ Running "kind" validation checks
✅ Detected kind version "0.22.0"
ℹ️  Using Cilium version 1.15.0
🔮 Auto-detected cluster name: kind-clab-bgp-cplane-demo
🔮 Auto-detected kube-proxy has been installed
```
To verify that BGP is enabled, we can use the following command:  
<u><b>Command:</b></u>
```bash
cilium config view | grep enable-bgp
```
<u><small>Output:</small></u>
```
enable-bgp-control-plane                          true
```

Next, we are going to deploy our BGP Peering Policies and verify that the BGP sessions are established.
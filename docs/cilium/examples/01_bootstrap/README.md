# Bootstrap
## Starting a cluster without a CNI plugin or kube-proxy
In this example, a [kind cluster](https://kind.sigs.k8s.io/) has been initialized without a CNI plugin or kube-proxy.  
This can be done by starting a [kind cluster](https://kind.sigs.k8s.io/) with the following configuration:  
/etc/kind/kind-config.yaml  
```yaml
---
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  # localhost.run proxy
  - containerPort: 32042
    hostPort: 32042
  # Hubble relay
  - containerPort: 31234
    hostPort: 31234
  # Hubble UI
  - containerPort: 31235
    hostPort: 31235
- role: worker
- role: worker
networking:
  disableDefaultCNI: true
  kubeProxyMode: none
```

I did the same for my [k3s cluster](https://k3s.io/) by disabling flannel, kube-proxy, servicelb, network-policy, and traefik.  
This can be achieved by running the following command:  
```bash
curl -sfL https://get.k3s.io | K3s_token=$k3s_token_value sh -s - \
    --write-kubeconfig-mode 644 \
    --flannel-backend=none \
    --disable-kube-proxy \
    --disable servicelb \
    --disable-network-policy \
    --disable=traefik \
    --cluster-init \
```
In these examples I will follow along with the [kind cluster](https://kind.sigs.k8s.io/) example.  
To start a [kind cluster](https://kind.sigs.k8s.io/) with the above configuration, run the following command:  
```bash
kind create cluster --config /etc/kind/kind-config.yaml
```
After the cluster has been created, you can check on the nodes with the `kubectl get nodes` command.  
This will then show the following output  
```bash
NAME                 STATUS     ROLES           AGE    VERSION
kind-control-plane   NotReady   control-plane   107m   v1.29.2
kind-worker          NotReady   <none>          107m   v1.29.2
kind-worker2         NotReady   <none>          107m   v1.29.2
```
**Note:** The nodes are in the NotReady status because there is no CNI plugin or kube-proxy running.
You can now install [Cilium](https://cilium.io/)! 
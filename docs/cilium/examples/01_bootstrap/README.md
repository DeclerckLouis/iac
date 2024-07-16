# Bootstrap
In this example, the k3s cluster has been initialized without flannel, kube-proxy, servicelb, network-policy, and traefik.  
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
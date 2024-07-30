# Automatic IPAM
In the first challenge, we created a service with a static IP in the manifest.  
Let's now see how IPs can be automatically assigned to services by Cilium.  

## The Need for LoadBalancer IP Address Management

To allocate IP addresses for Kubernetes Services that are exposed outside of a cluster, you need a resource of the type LoadBalancer.  
When you use Kubernetes on a cloud provider, these resources are automatically managed for you and their IP and/or DNS are automatically allocated.  

However if you run on a bare-metal cluster, you need another tool to allocate that address as Kubernetes doesn't natively support this function.  
Typically you would have to install and use something like MetalLB for this purpose. Maintaining yet another networking tool can be cumbersome.  
In Cilium 1.13, you no longer need MetalLB for this use case: Cilium can allocate IP Addresses to Kubernetes LoadBalancer Service.  
Let's have a look at this feature in more details.

## Configure IP pool
apply manifest
```bash
kubectl apply -f pool-blue.yaml
```

Change l2policy so that it allows LoadBalancerIPs
```bash
kubectl apply -f l2policy.yaml
```

## create service
expose the deathstar deployment with a LoadBalancer service
```bash
kubectl expose deployment deathstar --name deathstar-3 --port 80 --type LoadBalancer
```

This won't get an IP since it doesn't match the label blue, lets fix that  
```bash
kubectl label svc deathstar-3 color=blue
```

check now
```bash
kubectl get svc deathstar-3 --show-labels
```

output:
```
NAME          TYPE           CLUSTER-IP   EXTERNAL-IP   PORT(S)        AGE   LABELS
deathstar-3   LoadBalancer   10.96.9.66   12.0.0.128    80:32171/TCP   12s   color=blue
```
**Very important that the labels match**

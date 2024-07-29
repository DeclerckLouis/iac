# L2Announcement policies
## This is what's breaking my current setup
## Cilium setup
in the example a kind cluster is used.  
The cilium setup is as follows:  
```bash
cilium install \
  --version v1.16.0 \
  --set kubeProxyReplacement=true \
  --set k8sServiceHost="kind-control-plane" \
  --set k8sServicePort=6443 \
  --set l2announcements.enabled=true \
  --set l2announcements.leaseDuration="3s" \
  --set l2announcements.leaseRenewDeadline="1s" \
  --set l2announcements.leaseRetryPeriod="500ms" \
  --set devices="{eth0,net0}" \
  --set externalIPs.enabled=true \
  --set operator.replicas=2
  ```
**VERY IMPORTANT TO NOTE** 
**THE LEASE DURATION CAN BE SET LONGER OR SHORTER**
**IN THIS EXAMPLE, IT IS SET TO 3 SECONDS**
**THAT MEANS, IF THE NODE DIES, IT WILL BE PICKED UP BY ANOTHER NODE IN 3 SECONDS (I THINK)**
**PLEASE REFER TO [04_NODE_FAILURE](../04_node_failure/)**



## The l2announcements
Deploy the deathstar deploymnet:
```bash
kubectl apply -f deathstar.yaml
```

Check on progress:
```bash
kubectl rollout status deployment deathstar
```

Inspect services:
```bash
kubectl get svc deathstar --show-labels
```

Output:
```
NAME        TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE     LABELS
deathstar   ClusterIP   10.96.190.135   12.0.0.100    80/TCP    5m15s   color=red   
```

Gice it an IP address from outside the cluster:
```bash
SVC_IP=12.0.0.100
kubectl patch service deathstar -p '{"spec":{"externalIPs":["'$SVC_IP'"]}}'
```

output:
```
NAME        TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
deathstar   ClusterIP   10.96.190.135   12.0.0.100    80/TCP    8m43s
```
**At this point the service is not reachable from the outside**
**Is this some kind of magic?**

Now, deploy a l2announcements policy:
```bash
kubectl apply -f l2policy.yaml
```

**will still not work due to the selector on the policy**
relabel the service:
```bash
kubectl label svc deathstar color=blue --overwrite
```

and connect
```bash
curl --connect-timeout 1 http://$SVC_IP/v1/
```
This should work except that it doesn't for me
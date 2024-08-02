# Load Balancing needs
The Cilium Service Mesh Gateway API Controller requires the ability to create LoadBalancer Kubernetes services.  
Since we are using Kind on a Virtual Machine, we do not benefit from an underlying Cloud Provider's load balancer integration.    
For this lab, we will use Cilium's own LoadBalancer capabilities to provide IP Address Management (IPAM) and Layer 2 announcement of IP addresses assigned to LoadBalancer services.  

## Application deployment
Deploy the echo-servers application:
```bash
kubectl apply -f echo-servers.yaml
```

## gateway and HTTProute deployment
Deploy the gateway and HTTProute:
```bash
kubectl apply -f gateway.yaml -f httproute.yaml
```
when running `kubectl get svc`, you should see the LoadBalancer service with an external IP address.  

**NOTE:** In order for this while thing to work, you must have installed k3s and cilium properly (gateway API enabled, IPPool created, etc.)  
Retrieve the gateway API IP address:
```bash
GATEWAY=$(kubectl get gateway cilium-gw -o jsonpath='{.status.addresses[0].value}')
echo $GATEWAY
```
**NOTE:** Since the gateway doesn't have a "hostname" specified, you will need to use the IP address to access the service.  
Make HTTP Requests to the echo-servers:
```bash
curl --fail -s http://$GATEWAY/echo
```
If this fails from your machine, you might have `l2announcements` configured incorrectly. (Check the [l2announcements directory(../l2announcements/) for more information)])
Otherwise, run it a couple of times to see the different responses from the echo-servers.  
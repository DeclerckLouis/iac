# A short Demo of Cilium
## Getting started
### 1. deploy a demo application 
This is from the [Cilium github](https://github.com/cilium/cilium/tree/main/examples/minikube) and maintained by the Cilium team 
<u><b>Command:</b></u>
```bash
kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/HEAD/examples/minikube/http-sw-app.yaml
```
**Note:** Since the Cilium team is a big fan of Star Wars, they have created a demo application that is based on the Star Wars universe.

You can now check on the pods and services with `kubectl get pods,svc`
<small>Output:</small> 
```bash
NAME                            READY   STATUS    RESTARTS   AGE
pod/deathstar-b4b8ccfb5-4w9bn   1/1     Running   0          96s
pod/deathstar-b4b8ccfb5-h4987   1/1     Running   0          96s
pod/tiefighter                  1/1     Running   0          96s
pod/xwing                       1/1     Running   0          96s

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/deathstar    ClusterIP   10.96.44.135   <none>        80/TCP    96s
service/kubernetes   ClusterIP   10.96.0.1      <none>        443/TCP   133m
```
Each pod will also be represented in Cilium as an endpoint.  
You can check on the endpoints with the `kubectl get cep --all-namespaces` command.
<small>Output:</small> 
```bash
NAMESPACE            NAME                                      SECURITY IDENTITY   ENDPOINT STATE   IPV4           IPV6
default              deathstar-b4b8ccfb5-4w9bn                 47705               ready            10.244.2.77    
default              deathstar-b4b8ccfb5-h4987                 47705               ready            10.244.1.166   
default              tiefighter                                61147               ready            10.244.2.83    
default              xwing                                     46290               ready            10.244.1.4     
kube-system          coredns-76f75df574-4mxhn                  21550               ready            10.244.1.162   
kube-system          coredns-76f75df574-sbhff                  21550               ready            10.244.2.186   
local-path-storage   local-path-provisioner-7577fdbbfb-q7pfw   56764               ready            10.244.2.126 
```
**Note:** A cool thing to note here, is that cilium also supports ipv6!

### 2. Test the application (NO Policies)
To help with understanding how this demo works, here's some background information:
- In this demo, we are the bad guys that want to protect the `deathstar` service.
- The `deathstar` service is the main service that the `xwing` and `tiefighter` pods will try to communicate with.
- The `xwing` pod is the good guy  and will try to communicate with (and destroy) the `deathstar` service.
- The `tiefighter` pod is the bad guy and will try to communicate (and just live happy) with the `deathstar` service.

To test the application, we will try to communicate with the `deathstar` service from both the `xwing` and `tiefighter` pods.  
To do this, we will use the `curl` command to send a request to the `deathstar` service: 
From the `tiefigher` pod:
<u><b>Command:</b></u>
```bash
kubectl exec tiefighter -- \
  curl -s -XPOST deathstar.default.svc.cluster.local/v1/request-landing
```
<u><small>Output:</small></u> 
```bash
Ship landed
```
From the `xwing` pod:
<u><b>Command:</b></u>
```bash
kubectl exec xwing -- \
  curl -s -XPOST deathstar.default.svc.cluster.local/v1/request-landing
```
<u><small>Output:</small></u> 
```bash
Ship landed
```
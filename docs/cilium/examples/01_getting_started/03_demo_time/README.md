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
**Note:** The `deathstar` service is not protected by any policies, so both the `xwing` and `tiefighter` pods are able to communicate with it.
Security wise, this is not good. For the good guys, this is great!

### 3. Apply a Network Policy (and test it)
The policy that we will apply also comes from the [Cilium github](https://raw.githubusercontent.com/cilium/cilium/HEAD/examples/minikube/sw_l3_l4_policy.yaml) and is maintained by the Cilium team.  
This policy will only allow pods of the `empire` org to communicate with the `deathstar` service.
<u><b>Command:</b></u>
```bash
kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/HEAD/examples/minikube/sw_l3_l4_policy.yaml
```
<u><small>Output:</small></u>
```bash
ciliumnetworkpolicy.cilium.io/rule1 created
```

To test the policy, we will try to communicate with the `deathstar` service from both the `xwing` and `tiefighter` pods.
From the `tiefigher` pod:
<u><b>Command:</b></u>
```bash
kubectl exec tiefighter -- \
  curl -s -XPOST deathstar.default.svc.cluster.local/v1/request-landing
```
<u><small>Output:</small></u> 
```bash
ship landed
```
From the `xwing` pod:
<u><b>Command:</b></u>
```bash
kubectl exec xwing -- \
  curl -s -XPOST deathstar.default.svc.cluster.local/v1/request-landing
```
This command will keep running for a long time and will eventually time out.

### 4. Tighter rules
To make the policy even more secure, we can add a rule that only allows the `tiefigher` pod to communicate with specific paths on the `deathstar` service.  
Since the the current policies allow pods to either access everything or nothing at all, we will need to create a new policy (layer 7) that restricts this.  
Currently, this is what can happen:
<u><b>Command:</b></u>
```bash
kubectl exec tiefighter -- \
  curl -s -XPUT deathstar.default.svc.cluster.local/v1/exhaust-port
```
<u><small>Output:</small></u> 
```bash
Panic: deathstar exploded

goroutine 1 [running]:
main.HandleGarbage(0x2080c3f50, 0x2, 0x4, 0x425c0, 0x5, 0xa)
        /code/src/github.com/empire/deathstar/
        temp/main.go:9 +0x64
main.main()
        /code/src/github.com/empire/deathstar/
        temp/main.go:5 +0x85
```
To make the policy more secure, we will create a new policy that only allows the `tiefighter` pod to communicate with the `/v1/request-landing` path on the `deathstar` service.
This policy will also come from the [Cilium github](https://raw.githubusercontent.com/cilium/cilium/HEAD/examples/minikube/sw_l7_policy.yaml) and is maintained by the Cilium team.
<u><b>Command:</b></u>
```bash
kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/HEAD/examples/minikube/sw_l3_l4_l7_policy.yaml
```
<u><small>Output:</small></u>
```bash
ciliumnetworkpolicy.cilium.io/rule1 configured
```

To test the policy, we will try to communicate with the `deathstar` service at the `/v1/exhaust-port` path from the `tiefighter` pod.
From the `tiefigher` pod:
<u><b>Command:</b></u>
```bash
kubectl exec tiefighter -- curl -s -XPUT deathstar.default.svc.cluster.local/v1/exhaust-port
```

<u><small>Output:</small></u> 
```bash
Access denied
```
**Note:** The `tiefighter` pod is not able to communicate with the `deathstar` service at the `/v1/exhaust-port` path,  
but it is still able to communicate with the `deathstar` service at the `/v1/request-landing` path.  
This is because cilium can enforce policies at layer 7 (application layer) as well as layer 3/4 (network layer).


# HTTP Demo Time (bookinfo)
## Table of Contents
- [HTTP Demo Time (bookinfo)](#http-demo-time-bookinfo)
  - [Table of Contents](#table-of-contents)
  - [Getting started](#getting-started)
    - [1. deploy the bookinfo application](#1-deploy-the-bookinfo-application)
    - [2. Deploy the Gateway](#2-deploy-the-gateway)
    - [2. Gateway Path Matching](#2-gateway-path-matching)
    - [3. Gateway Header Matching](#3-gateway-header-matching)

## Getting started
### 1. deploy the bookinfo application
This is from the [Istio github](https://github.com/istio/istio/tree/master/samples/bookinfo) and maintained by the Istio team.  
<u><b>Command:</b></u>
```bash
kubectl apply -f https://raw.githubusercontent.com/istio/istio/master/samples/bookinfo/platform/kube/bookinfo.yaml
```

<u><small>Output:</small></u>
```bash
service/details created
...
serviceaccount/bookinfo-productpage created
deployment.apps/productpage-v1 created
```
Now, we can check on the pods and the services:  
<u><b>Command:</b></u>
```bash
kubectl get pods,svc
```

<u><small>Output:</small></u>
```bash
NAME                                 READY   STATUS    RESTARTS   AGE
pod/details-v1-65599dcf88-rz7sz      1/1     Running   0          4m2s
pod/productpage-v1-9487c9c5b-4bnm2   1/1     Running   0          4m2s
pod/ratings-v1-59b99c644-hpsff       1/1     Running   0          4m2s
pod/reviews-v1-5985998544-ldgbv      1/1     Running   0          4m2s
pod/reviews-v2-86d6cc668-xqgmk       1/1     Running   0          4m2s
pod/reviews-v3-dbb5fb5dd-kd9ms       1/1     Running   0          4m2s

NAME                  TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
service/details       ClusterIP   10.96.242.180   <none>        9080/TCP   4m2s
service/kubernetes    ClusterIP   10.96.0.1       <none>        443/TCP    39m
service/productpage   ClusterIP   10.96.60.117    <none>        9080/TCP   4m2s
service/ratings       ClusterIP   10.96.165.155   <none>        9080/TCP   4m2s
service/reviews       ClusterIP   10.96.110.211   <none>        9080/TCP   4m2s
```
Everything seems to be up and running.

### 2. Deploy the Gateway
The gateway can be deployed with the following manifest:  
<u><b>Command:</b></u>
```bash
# The contents of basic-http.yaml can be found in this directory
kubectl apply -f basic-http.yaml
```

<u><small>Output:</small></u>
```bash
gateway.gateway.networking.k8s.io/my-gateway created
httproute.gateway.networking.k8s.io/http-app-1 created
```
The gateway has been deployed and is working. We can review the configuration:
<u><small>Gateway.yaml</small></u>

```yaml
---
spec:
  gatewayClassName: cilium
  listeners:
  - protocol: HTTP
    port: 80
    name: web-gw
    allowedRoutes:
      namespaces:
        from: Same
```
In this section the gatewayClassName field uses the `cilium` gateway controller.  
This is the gatewayClass that was deployed in the [01_setup](../01_setup/) section.  
The gateway will listen on port `80` and allow traffic from the `same` namespace. 
If we were to change the `same` to `all`, then the gateway would allow traffic from all namespaces.  
This would allow us to use a single gateway for multiple namespaces.

<u><small>HTTPRoute</small></u>

```yaml
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /details
    backendRefs:
    - name: details
      port: 9080
```
This first rule will match any path that starts with `/details` and send the traffic to the `details` service on port `9080`.

```yaml
 rules:
  - matches:
   - headers:
      - type: Exact
        name: magic
        value: foo
      queryParams:
      - type: Exact
        name: great
        value: example
      path:
        type: PathPrefix
        value: /
      method: GET
    backendRefs:
    - name: productpage
      port: 9080
```
This second rule will match any traffic that has the header `magic: foo`, the query parameter `great=example`, the path `/`, and the method `GET`.  
This is just an example of how specific the rules can be and how Layer 7 traffic can be controlled.

Check the services now that the gateway has been deployed:  
<u><b>Command:</b></u>
```bash
kubectl get svc
```

<u><small>Output:</small></u>
```bash
NAME                        TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)        AGE
cilium-gateway-my-gateway   LoadBalancer   10.96.168.1     172.18.255.203   80:31361/TCP   14m
details                     ClusterIP      10.96.242.180   <none>           9080/TCP       21m
kubernetes                  ClusterIP      10.96.0.1       <none>           443/TCP        56m
productpage                 ClusterIP      10.96.60.117    <none>           9080/TCP       21m
ratings                     ClusterIP      10.96.165.155   <none>           9080/TCP       21m
reviews                     ClusterIP      10.96.110.211   <none>           9080/TCP       21m
```
The `cilium-gateway-my-gateway` service is now a `LoadBalancer` service and has an external IP address.  
The same external IP address is also associated with the `cilium-gateway-my-gateway` service.  
<u><b>Command:</b></u>
```bash
kubectl get gateway
```

<u><small>Output:</small></u>
```bash
NAME         CLASS    ADDRESS          PROGRAMMED   AGE
my-gateway   cilium   172.18.255.203   True         24m
```

To get the IP address:  
<u><b>Command:</b></u>
```bash
GATEWAY=$(kubectl get gateway my-gateway -o jsonpath='{.status.addresses[0].value}')
echo $GATEWAY
```

<u><small>Output:</small></u>
```bash
172.18.255.203
```

### 2. Gateway Path Matching
To test the application, we can use the `curl` command to send a request to the `/details` page:  
<u><b>Command:</b></u>
```bash
curl --fail -s http://$GATEWAY/details/1 | jq
```

<u><small>Output:</small></u>
```json
{
  "id": 1,
  "author": "William Shakespeare",
  "year": 1595,
  "type": "paperback",
  "pages": 200,
  "publisher": "PublisherA",
  "language": "English",
  "ISBN-10": "1234567890",
  "ISBN-13": "123-1234567890"
}
```
The request was successful and the details of the book were returned.

### 3. Gateway Header Matching
To test the application, we can use the `curl` command to send a request to the `/` page with the header `magic: foo`:  
<u><b>Command:</b></u>
```bash
curl -v -H 'magic: foo' "http://$GATEWAY?great=example"
```
This works because the header `magic: foo` and the query parameter `great=example` are both present in the request.
# Traffic Splitting (A/B Testing)
In this example, we will show you how to use Cilium to split traffic between two different versions of a service.
## Table of Contents
- [Traffic Splitting (A/B Testing)](#traffic-splitting-ab-testing)
  - [Table of Contents](#table-of-contents)
  - [Deploy an application](#deploy-an-application)
  - [Load-Balancing the traffic](#load-balancing-the-traffic)
    - [Deploy application](#deploy-application)
    - [Check the traffic splitting](#check-the-traffic-splitting)
  - [99/1 Split](#991-split)

## Deploy an application
First, we will deploy a `echo` application that will reply to the client with information about the pod and node receiving the request.  
The manifest for the application can be found [here](https://raw.githubusercontent.com/cilium/cilium/HEAD/examples/minikube/echo/echo.yaml).  
<u><b>Command:</b></u>
```bash
kubectl apply -f echo-servers.yaml
```

To check if the pods are up and running, we can use the following command:
<u><b>Command:</b></u>
```bash
kubectl get pods
```

<u><small>Output:</small></u>
```bash
NAME                             READY   STATUS    RESTARTS   AGE
details-v1-65599dcf88-mhxmr      1/1     Running   0          63m
echo-1-6d99ff955f-ww7rd          1/1     Running   0          3m11s
echo-2-74cb847c7c-8cvjl          1/1     Running   0          3m11s
my-nginx-96b69b744-98vjm         1/1     Running   0          46m
productpage-v1-9487c9c5b-hx5pl   1/1     Running   0          63m
ratings-v1-59b99c644-tt2qm       1/1     Running   0          63m
reviews-v1-5985998544-29nrb      1/1     Running   0          63m
reviews-v2-86d6cc668-c24hk       1/1     Running   0          63m
reviews-v3-dbb5fb5dd-xz5vl       1/1     Running   0          63m
```
To check on the services, we can use the following command:
<u><b>Command:</b></u>
```bash
kubectl get svc
```

<u><small>Output:</small></u>
```bash
NAME                             READY   STATUS    RESTARTS   AGE
details-v1-65599dcf88-mhxmr      1/1     Running   0          63m
echo-1-6d99ff955f-ww7rd          1/1     Running   0          3m11s
echo-2-74cb847c7c-8cvjl          1/1     Running   0          3m11s
my-nginx-96b69b744-98vjm         1/1     Running   0          46m
productpage-v1-9487c9c5b-hx5pl   1/1     Running   0          63m
ratings-v1-59b99c644-tt2qm       1/1     Running   0          63m
reviews-v1-5985998544-29nrb      1/1     Running   0          63m
reviews-v2-86d6cc668-c24hk       1/1     Running   0          63m
reviews-v3-dbb5fb5dd-xz5vl       1/1     Running   0          63m
```

**Note:** The `echo-1` and `echo-2` services are currently using `ClusterIP` services.  
Therefore, there is currently no access from outisde the cluster to these services.

## Load-Balancing the traffic

### Deploy application
First, create the HTTPRoute with the following manifest:
<u><small>load-balancing-http-route.yaml</small></u>
```yaml
---
apiVersion: gateway.networking.k8s.io/v1beta1
kind: HTTPRoute
metadata:
  name: load-balancing-route
spec:
  parentRefs:
    - name: my-gateway
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /echo
      backendRefs:
        - kind: Service
          name: echo-1
          port: 8080
          weight: 50
        - kind: Service
          name: echo-2
          port: 8090
          weight: 50
```
This Rule is essentially a simple L7 proxy route: for HTTP traffic with a path starting with /echo, forward the traffic over to the echo-1 and echo-2 Services over port 8080 and 8090 respectively.
**Note:** The `weight` field is used to split the traffic between the two services. In this case it's set to 50/50.  

The manifest can be applied with the following command:
<u><b>Command:</b></u>
```bash
kubectl apply -f load-balancing-http-route.yaml
```

### Check the traffic splitting
First, we need the IP address of the gateway.
<u><b>Command:</b></u>
```bash
GATEWAY=$(kubectl get gateway my-gateway -o jsonpath='{.status.addresses[0].value}')
echo $GATEWAY
```

<u><small>Output:</small></u>
```
172.18.255.202
```


To check if the traffic is being split between the two services, we can use the `curl` command to send a request to the `echo` service:

<u><b>Command:</b></u>
```bash
curl --fail -s http://$GATEWAY/echo
```

<u><small>Output:</small></u>
```
Hostname: echo-2-74cb847c7c-8cvjl

Pod Information:
        node name:      kind-worker
        pod name:       echo-2-74cb847c7c-8cvjl
        pod namespace:  default
        pod IP: 10.244.2.208

Server values:
        server_version=nginx: 1.12.2 - lua: 10010

Request Information:
        client_address=10.244.1.70
        method=GET
        real path=/echo
        query=
        request_version=1.1
        request_scheme=http
        request_uri=http://172.18.255.202:8080/echo

Request Headers:
        accept=*/*  
        host=172.18.255.202  
        user-agent=curl/8.5.0  
        x-envoy-internal=true  
        x-forwarded-for=172.18.0.1  
        x-forwarded-proto=http  
        x-request-id=3099fb90-82e0-4532-93a8-38321e7ff772  

Request Body:
        -no body in request-
```
In this response, we can see that the request was forwarded to the `echo-2` service.  
If we run the command again a couple times, we should see that the request is forwarded to the `echo-1` service.  
To speed it all up, we can automate it:  
<u><b>Command:</b></u>
```bash
for _ in {1..500}; do
  curl -s -k "http://$GATEWAY/echo" >> curlresponses.txt;
done
grep -o "Hostname: echo-." curlresponses.txt | sort | uniq -c
```

<u><small>Output:</small></u>
```
    241 Hostname: echo-1
    259 Hostname: echo-2
```
In this output, we can see that the traffic is being split between the two services.  
It might not be exactly 50/50, but it should be close.  

## 99/1 Split
if we want to split the traffic 99/1, we can change the `weight` field in the `load-balancing-http-route.yaml` file to 99/1.  
<u><small>load-balancing-http-route.yaml</small></u>
```yaml
apiVersion: gateway.networking.k8s.io/v1beta1
kind: HTTPRoute
spec:
  parentRefs:
  - group: gateway.networking.k8s.io
    kind: Gateway
    name: my-gateway
  rules:
  - backendRefs:
    - group: ""
      kind: Service
      name: echo-1
      port: 8080
      weight: 99
    - group: ""
      kind: Service
      name: echo-2
      port: 8090
      weight: 1
    matches:
    - path:
        type: PathPrefix
        value: /echo
```
After changing the `weight` field, we can apply the manifest with the following command:
<u><b>Command:</b></u>
```bash
kubectl apply -f load-balancing-http-route.yaml
```

if we repeat the previous test now, we should see that the traffic is split 99/1 between the two services.  
<u><b>Command:</b></u>
```bash
for _ in {1..500}; do
  curl -s -k "http://$GATEWAY/echo" >> curlresponses991.txt;
done
grep -o "Hostname: echo-." curlresponses991.txt | sort | uniq -c
```

<u><small>Output:</small></u>
```
    992 Hostname: echo-1
      8 Hostname: echo-2
```
Here, we can see that the traffic is split 99/1 between the two services.

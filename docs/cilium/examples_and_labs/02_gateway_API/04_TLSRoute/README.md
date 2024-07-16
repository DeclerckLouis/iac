# TLSRoute
In the previous task, we looked at the `TLS Termination` and how the Gateway can terminate HTTPS traffic from a client and route the unencrypted HTTP traffic based on HTTP properties, like path, method or headers.

In this task, we will look at a feature that was introduced in Cilium 1.14: `TLSRoute`. This resource lets you passthrough TLS traffic from the client all the way to the Pods - meaning the traffic is encrypted end-to-end.
## Table of Contents
- [TLSRoute](#tlsroute)
  - [Table of Contents](#table-of-contents)
  - [Deploy the Demo app](#deploy-the-demo-app)
  - [Deploy the Gateway](#deploy-the-gateway)
  - [Test the application](#test-the-application)


## Deploy the Demo app
In this example, we will configure NGINX to listen on port 443 and serve a simple HTML page.  
We will then deploy a `TLSRoute` to route the traffic to the NGINX Pod.

The nginx config is as follows:  
<u><small>nginx.conf</small></b></u>
```nginx
events {
}

http {
  log_format main '$remote_addr - $remote_user [$time_local]  $status '
  '"$request" $body_bytes_sent "$http_referer" '
  '"$http_user_agent" "$http_x_forwarded_for"';
  access_log /var/log/nginx/access.log main;
  error_log  /var/log/nginx/error.log;

  server {
    listen 443 ssl;

    root /usr/share/nginx/html;
    index index.html;

    server_name nginx.cilium.rocks;
    ssl_certificate /etc/nginx-server-certs/tls.crt;
    ssl_certificate_key /etc/nginx-server-certs/tls.key;
  }
}
```

We can see that the server is listening on port 443 and serving the HTML page from `/usr/share/nginx/html`.
After saving the config, we can create a kubernetes ConfigMap with the nginx config:  
<u><b>Command:</b></u>
```bash
kubectl create configmap nginx-configmap --from-file=nginx.conf=./nginx.conf
```

This creates a configmap called `nginx-configmap` that contains the nginx config.
Now, we can deploy the nginx Pod:  
<u><b>Command:</b></u>
```bash
kubectl apply -f tls-service.yaml
```

<u><small>Output:</small></u>
```
service/my-nginx created
deployment.apps/my-nginx created
```

Verify that the Service and Deployment are running:  
<u><b>Command:</b></u>
```bash
kubectl get svc,deployment my-nginx
```

<u><small>Output:</small></u>
```
NAME               TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
service/my-nginx   ClusterIP   10.96.4.214   <none>        443/TCP   81s

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/my-nginx   1/1     1            1           81s
```

There we go, it's up and running!

## Deploy the Gateway
We can review the [tls-gateway](./tls-gateway.yaml) and [tls-route](./tls-gateway.yaml) manifests:  
<u><small>tls-gateway.yaml</small></u>
```yaml
spec:
  gatewayClassName: cilium
  listeners:
  - name: https
    hostname: "nginx.cilium.rocks"
    port: 443
    protocol: TLS
    tls:
      mode: Passthrough
    allowedRoutes:
      namespaces:
        from: All
```
**Note:** An important thing to note here, is the use of the `Passthrough` mode.  
Previously, we used the HTTPRoute resource, this time, we're using the TLSRoute:  
<u><small>tls-route.yaml</small></u>
```yaml
apiVersion: gateway.networking.k8s.io/v1beta1
kind: TLSRoute
metadata:
  name: nginx
spec:
  parentRefs:
  - name: cilium-tls-gateway
  hostnames:
  - "nginx.cilium.rocks"
  rules:
  - backendRefs:
    - name: my-nginx
      port: 443
```

Here's an overview of the differences in using `Terminate`and `Passthrough`:
```
In Terminate:
    Client -> Gateway: HTTPS
    Gateway -> Pod: HTTP

In Passthrough:
    Client -> Gateway: HTTPS
    Gateway -> Pod: HTTPS
```
The gateway does **not** actually inspect the traffic aside from using the SNI header for routing.  
The `hostnames`field defines a set of SNI names that should match agains the SNI attribute of the `TLS ClientHello` message in the TLS Handshake.  

Deploying the Gateway and TLSRoute:  
<u><b>Command:</b></u>
```bash
kubectl apply -f tls-gateway.yaml -f tls-route.yaml
```

<u><small>Output:</small></u>
```
gateway.gateway.networking.k8s.io/cilium-tls-gateway unchanged
tlsroute.gateway.networking.k8s.io/nginx configured
```
Verify that the Gateway has a LoadBalancer IP:  
<u><b>Command:</b></u>
```bash
kubectl get gateway cilium-tls-gateway
```

<u><small>Output:</small></u>
```
NAME                 CLASS    ADDRESS          PROGRAMMED   AGE
cilium-tls-gateway   cilium   172.18.255.205   True         4m41s
```

And assign the IP address to a variable so that we can use it later:  
<u><b>Command:</b></u>
```bash
GATEWAY_IP=$(kubectl get gateway cilium-tls-gateway -o jsonpath='{.status.addresses[0].value}')
echo $GATEWAY_IP
```

<u><small>Output:</small></u>
```
172.18.255.205
```

## Test the application
Make a request over HTTPS to the gateway:  
<u><b>Command:</b></u>
```bash
curl -v \
  --resolve "nginx.cilium.rocks:443:$GATEWAY_IP" \
  "https://nginx.cilium.rocks:443"
```

<u><small>Output:</small></u>
```
* Added nginx.cilium.rocks:443:172.18.255.205 to DNS cache
* Hostname nginx.cilium.rocks was found in DNS cache
*   Trying 172.18.255.205:443...
* Connected to nginx.cilium.rocks (172.18.255.205) port 443
* ALPN: curl offers h2,http/1.1
* TLSv1.3 (OUT), TLS handshake, Client hello (1):
*  CAfile: /etc/ssl/certs/ca-certificates.crt
*  CApath: /etc/ssl/certs
* TLSv1.3 (IN), TLS handshake, Server hello (2):
* TLSv1.3 (IN), TLS handshake, Encrypted Extensions (8):
* TLSv1.3 (IN), TLS handshake, Certificate (11):
* TLSv1.3 (IN), TLS handshake, CERT verify (15):
* TLSv1.3 (IN), TLS handshake, Finished (20):
* TLSv1.3 (OUT), TLS change cipher, Change cipher spec (1):
* TLSv1.3 (OUT), TLS handshake, Finished (20):
* SSL connection using TLSv1.3 / TLS_AES_256_GCM_SHA384 / X25519 / RSASSA-PSS
* ALPN: server accepted http/1.1
* Server certificate:
*  subject: O=mkcert development certificate; OU=root@server
*  start date: Jul 16 11:49:04 2024 GMT
*  expire date: Oct 16 11:49:04 2026 GMT
*  subjectAltName: host "nginx.cilium.rocks" matched cert's "*.cilium.rocks"
*  issuer: O=mkcert development CA; OU=root@server; CN=mkcert root@server
*  SSL certificate verify ok.
*   Certificate level 0: Public key type RSA (2048/112 Bits/secBits), signed using sha256WithRSAEncryption
*   Certificate level 1: Public key type RSA (3072/128 Bits/secBits), signed using sha256WithRSAEncryption
* using HTTP/1.x
> GET / HTTP/1.1
> Host: nginx.cilium.rocks
> User-Agent: curl/8.5.0
> Accept: */*
> 
* TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
* TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
* old SSL session ID is stale, removing
< HTTP/1.1 200 OK
< Server: nginx/1.27.0
< Date: Tue, 16 Jul 2024 12:40:03 GMT
< Content-Type: text/html
< Content-Length: 100
< Last-Modified: Tue, 16 Jul 2024 12:06:13 GMT
< Connection: keep-alive
< ETag: "66966235-64"
< Accept-Ranges: bytes
< 
<html>
<h1>Welcome to our webserver listening on port 443.</h1>
</br>
<h1>Cilium rocks.</h1>
</html
* Connection #0 to host nginx.cilium.rocks left intact

```
The data should be properly retrieved, using HTTPS (and thus, the TLS handshake was properly achieved).  
There are several things to note:  
- At the end, we get the HTML output `<h1>Cilium rocks.</h1>`
- the connection was established over port 443 `Connected to nginx.cilium.rocks (172.18.255.200) port 443 `
- We see a TLS handshake and TLS version negotiation
- We see a succesful certificate verification `SSL certificate verify ok`
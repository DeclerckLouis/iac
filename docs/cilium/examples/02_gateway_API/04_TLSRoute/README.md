# TLSRoute
In the previous task, we looked at the `TLS Termination` and how the Gateway can terminate HTTPS traffic from a client and route the unencrypted HTTP traffic based on HTTP properties, like path, method or headers.

In this task, we will look at a feature that was introduced in Cilium 1.14: `TLSRoute`. This resource lets you passthrough TLS traffic from the client all the way to the Pods - meaning the traffic is encrypted end-to-end.

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
```bash
service/my-nginx created
deployment.apps/my-nginx created
```

Verify that the Service and Deployment are running:
<u><b>Command:</b></u>
```bash
kubectl get svc,deployment my-nginx
```

<u><small>Output:</small></u>
```bash
NAME               TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
service/my-nginx   ClusterIP   10.96.4.214   <none>        443/TCP   81s

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/my-nginx   1/1     1            1           81s
```

There we go, it's up and running!
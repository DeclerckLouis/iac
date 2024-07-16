# Traffic Splitting (A/B Testing)
In this example, we will show you how to use Cilium to split traffic between two different versions of a service.
## Table of Contents
- [Traffic Splitting (A/B Testing)](#traffic-splitting-ab-testing)
  - [Table of Contents](#table-of-contents)
  - [Deploy an application](#deploy-an-application)
  - [Load-Balancing the traffic](#load-balancing-the-traffic)

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


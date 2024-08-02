## Intro
With this functionality, Cilium Gateway API lets us add, remove or edit HTTP Headers of incoming traffic.  
This is best validated by trying without and with the functionality. We’ll use the same echo servers.  

## Deploy HTTPRoute and test
deploy the HTTPRoute:
```bash
kubectl apply -f echo-header-http-route.yaml
```
You can see that this httproute can add a header to the incoming request.  
(it's commented out in the file, we can test without it first and then test with it)  
```yaml
    rules:
    - matches:
        - path:
            type: PathPrefix
            value: /cilium-add-a-request-header
    #   filters:
    #   - type: RequestHeaderModifier
    #    requestHeaderModifier:
    #      add:
    #      - name: my-cilium-header-name
    #        value: my-cilium-header-value
```
test it out:
```bash
curl --fail -s http://$GATEWAY/cilium-add-a-request-header
```
In the result you should see something like this:
```
Request Headers:
        accept=*/*  
        host=172.18.255.200  
        user-agent=curl/8.5.0  
        x-envoy-internal=true  
        x-forwarded-for=172.18.0.1  
        x-forwarded-proto=http  
        x-request-id=c5fe1b2f-8b4f-4e61-8309-e9909e0f8ac7  
```

## Edit the HTTPRoute and test again
Edit the HTTPRoute to add a header to the incoming request:
```yaml
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /cilium-add-a-request-header
    filters:
    - type: RequestHeaderModifier
      requestHeaderModifier:
        add:
        - name: my-cilium-header-name
          value: my-cilium-header-value
```
deploy the HTTPRoute:
```bash
kubectl apply -f echo-header-http-route.yaml
```
test it out:
```bash
curl --fail -s http://$GATEWAY/cilium-add-a-request-header
```
The output should now contain the header we added:
```
Request Headers:
        accept=*/*  
        host=172.18.255.200  
        my-cilium-header-name=my-cilium-header-value  
        user-agent=curl/8.5.0  
        x-envoy-internal=true  
        x-forwarded-for=172.18.0.1  
        x-forwarded-proto=http  
        x-request-id=f3559cae-de6f-405a-b623-905d1938fa1d  
```
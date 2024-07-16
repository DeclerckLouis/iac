# HTTPS demo time
In this demo, we will use https. This requires a certificate to be created and used.  
## Create TLS certificate and key
To create the certificate and key, we will use the following command:
<u><b>Command:</b></u>
```bash
mkcert '*.cilium.rocks'
```

<u><small>Output:</small></u>
```bash
Created a new local CA 💥
Note: the local CA is not installed in the system trust store.
Run "mkcert -install" for certificates to be trusted automatically ⚠️

Created a new certificate valid for the following names 📜
 - "*.cilium.rocks"

Reminder: X.509 wildcards only go one level deep, so this won't match a.b.cilium.rocks ℹ️

The certificate is at "./_wildcard.cilium.rocks.pem" and the key at "./_wildcard.cilium.rocks-key.pem" ✅

It will expire on 16 October 2026 🗓
```

Create a kubernetes secret with the certificate and key:
<u><b>Command:</b></u>
```bash
kubectl create secret tls demo-cert \
  --key=_wildcard.cilium.rocks-key.pem \
  --cert=_wildcard.cilium.rocks.pem
```

<u><small>Output:</small></u>
```bash
secret/demo-cert created
```

## Deploy the gateway
We'll deploy the HTTPS gateway with the following manifest:
<u><b>Command:</b></u>
```bash
# The contents of basic-https.yaml can be found in this directory
kubectl apply -f basic-https.yaml
```

Time to inspect the gateway:
It's almost the same as the HTTP gateway, but with a few changes.
```yaml
spec:
  gatewayClassName: cilium
  listeners:
  - name: https-1
    protocol: HTTPS
    port: 443
    hostname: "bookinfo.cilium.rocks"
    tls:
      certificateRefs:
      - kind: Secret
        name: demo-cert
```
In this section, the gateway will listen on port `443` and use the `bookinfo.cilium.rocks` hostname.  
You can also see that it will use the `demo-cert` secret for the TLS certificate.  
```yaml
spec:
  parentRefs:
  - name: tls-gateway
  hostnames:
  - "bookinfo.cilium.rocks"
```
This section will use the `tls-gateway` as the parent gateway.  

Check if the gateway has a load balancer IP:
<u><b>Command:</b></u>
```bash
kubectl get gateway tls-gateway
```

<u><small>Output:</small></u>
```bash
NAME          CLASS    ADDRESS          PROGRAMMED   AGE
tls-gateway   cilium   172.18.255.201   True         50s
```

Assign the IP address to a variable:
```bash
GATEWAY_IP=$(kubectl get gateway tls-gateway -o jsonpath='{.status.addresses[0].value}')
echo $GATEWAY_IP
```

<u><small>Output:</small></u>
```bash
172.18.255.201
```
## Test the application
First, we need to install the certificate in our system:
<u><b>Command:</b></u>
```bash
mkcert -install
```

Now we can test the application:
<u><b>Command:</b></u>
```bash
curl -s \
  --resolve bookinfo.cilium.rocks:443:${GATEWAY_IP} \
  https://bookinfo.cilium.rocks/details/1 | jq
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
All is working well!


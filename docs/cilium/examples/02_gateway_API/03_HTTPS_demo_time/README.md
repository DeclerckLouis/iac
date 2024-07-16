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


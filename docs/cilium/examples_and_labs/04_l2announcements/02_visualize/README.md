## Deploy service
Apply the new service
```bash
kubectl apply -f deathstar-2.yaml
```

CHeck the service
```bash
kubectl get svc deathstar-2
```

Output:
```
NAME          TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
deathstar-2   ClusterIP   10.96.48.20   12.0.0.101    80/TCP    2m29s
```

## prep visualization
Check on leases
```bash
kubectl get leases -n kube-system cilium-l2announce-default-deathstar-2 -o yaml
```

Output:
```
apiVersion: coordination.k8s.io/v1
kind: Lease
metadata:
  creationTimestamp: "2024-07-25T19:13:00Z"
  name: cilium-l2announce-default-deathstar-2
  namespace: kube-system
  resourceVersion: "6370"
  uid: 9895708c-ea9d-4c44-a113-516771f1ac97
spec:
  acquireTime: "2024-07-25T19:13:00.249232Z"
  holderIdentity: kind-worker
  leaseDurationSeconds: 3
  leaseTransitions: 0
  renewTime: "2024-07-25T19:16:23.654730Z"
```

Retrieve node hosting the lease
```bash
LEASE_NODE=$(kubectl -n kube-system get leases cilium-l2announce-default-deathstar-2 -o jsonpath='{.spec.holderIdentity}')
echo $LEASE_NODE
```

find cilium agent pod on that node
```bash
LEASE_CILIUM_POD=$(kubectl -n kube-system get pod -l k8s-app=cilium --field-selector spec.nodeName=$LEASE_NODE -o name)
echo $LEASE_CILIUM_POD
```

log into the cilium pod
```bash
kubectl -n kube-system exec -ti $LEASE_CILIUM_POD -- bash
```

install tcpdumt and termshark
```bash
apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install tcpdump termshark
```

launch tpcdump and filter arp
```bash
tcpdump -i any arp -w arp.pcap
```

## make request (from another machine)
make request to the service
```bash
# use external IP from the service here
curl --connect-timeout 1 http://12.0.0.101/v1/
```

## analyze results
stop tcpdump with ctrl+c
and save the pcap file
```bash
mkdir -p /root/.config/termshark/
echo -e "[main]\ndark-mode = true" > /root/.config/termshark/termshark.toml
termshark -r arp.pcap
```

launch termshark
```bash
TERM=xterm-256color termshark -r arp.pcap
```

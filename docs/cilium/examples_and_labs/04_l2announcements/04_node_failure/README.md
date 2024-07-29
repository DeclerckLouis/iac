Honestly, this is impressive.  
to check it out, please do the lab over at [Cilium labs](https://play.instruqt.com/embed/isovalent/tracks/cilium-lb-ipam-l2-announcements)

In essence it goes through the following:
## arping from external container (not in cluster)
```bash	
docker exec -ti clab-garp-demo-neighbor arping 12.0.0.100
```

output:
```
58 bytes from aa:c1:ab:82:39:af (12.0.0.100): index=2 time=3.999 usec
58 bytes from aa:c1:ab:82:39:af (12.0.0.100): index=3 time=4.212 usec
58 bytes from aa:c1:ab:82:39:af (12.0.0.100): index=4 time=4.433 usec
58 bytes from aa:c1:ab:82:39:af (12.0.0.100): index=5 time=4.360 usec
...
58 bytes from aa:c1:ab:82:39:af (12.0.0.100): index=14 time=3.678 usec
58 bytes from aa:c1:ab:82:39:af (12.0.0.100): index=15 time=3.916 usec
58 bytes from aa:c1:ab:82:39:af (12.0.0.100): index=16 time=3.812 usec
```
## Get node responsible for the lease
```bash
kubectl -n kube-system get leases cilium-l2announce-default-deathstar -o yaml | yq .spec
```

Output: some worker node  

## Node removal
Since our nodes are Docker containers, removing a node will not fully take down the datapath as the veth pair for it will stay behind.  
So in order to simulate a node removal, we'll need to identify the veth pair so we can take down the interface on the node.  

Kill the node:
```bash
docker kill kind-worker2
```

remove the veth pair:
```bash
ip link set net3 down
```

check the lease again:
```bash
kubectl -n kube-system get leases cilium-l2announce-default-deathstar -o yaml | yq .spec.holderIdentity
```

Checking back on the arping:
```
58 bytes from aa:c1:ab:db:23:3e (12.0.0.100): index=33 time=4.268 usec
58 bytes from aa:c1:ab:db:23:3e (12.0.0.100): index=34 time=4.085 usec
58 bytes from aa:c1:ab:db:23:3e (12.0.0.100): index=35 time=5.113 usec
58 bytes from aa:c1:ab:db:23:3e (12.0.0.100): index=36 time=3.883 usec
58 bytes from aa:c1:ab:db:23:3e (12.0.0.100): index=37 time=3.977 usec
Timeout
Timeout
Timeout
Timeout
58 bytes from aa:c1:ab:82:39:af (12.0.0.100): index=38 time=4.554 usec
58 bytes from aa:c1:ab:82:39:af (12.0.0.100): index=39 time=3.677 usec
58 bytes from aa:c1:ab:82:39:af (12.0.0.100): index=40 time=4.241 usec
58 bytes from aa:c1:ab:82:39:af (12.0.0.100): index=41 time=4.669 usec
58 bytes from aa:c1:ab:82:39:af (12.0.0.100): index=42 time=4.066 usec
```
**Just like that, the other node took over (see MAC)**

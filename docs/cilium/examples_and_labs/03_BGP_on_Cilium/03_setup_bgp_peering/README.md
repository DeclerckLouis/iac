# Setup BGP Peering
## Table of Contents
- [Setup BGP Peering](#setup-bgp-peering)
  - [Table of Contents](#table-of-contents)
  - [BGP configuration](#bgp-configuration)
  - [Verification](#verification)
  - [Deploying networking utility pods (netshoot)](#deploying-networking-utility-pods-netshoot)
  - [Test Connectivity with netshoot](#test-connectivity-with-netshoot)

## BGP configuration
The BGP configuration can be found in the [cilium-bgp-peering-policies.yaml](./cilium-bgp-peering-policies.yaml) file.  
Key aspects:  
- The remote peer address (`peerAddress`) and AS number (`peerASN`)
- The local AS number (`localASN`)  
In this example, we are using the IP addresses of our BGP peers: the TOR routers 10.0.0.1/32 (`tor0`) and 10.0.0.2/32 (`tor1`).  
**Note:** The BGP Configuration on Cilium is label-based.  
**The cilium managed nodes with a matching label will deploy a virtual router for BGP peering.**  
Please see also [the docs](https://docs.cilium.io/en/stable/network/bgp-control-plane/)  

The BGP policies can be deployed with the following command:  
<u><b>Command:</b></u>
```bash
kubectl apply -f cilium-bgp-peering-policies.yaml
```
<u><small>Output:</small></u>
```
ciliumbgppeeringpolicy.cilium.io/rack0 created
ciliumbgppeeringpolicy.cilium.io/rack1 created
```

## Verification
Now that BGP peering is setup, we can verify that the BGP sessions are established.  
We can do this by checking the BGP status on the TOR routers.  
<u><b>Command (tor0):</b></u>
```bash
docker exec -it clab-bgp-cplane-demo-tor0 vtysh -c 'show bgp ipv4 summary wide'
```
<u><small>Output:</small></u>
```
IPv4 Unicast Summary (VRF default):
BGP router identifier 10.0.0.1, local AS number 65010 vrf-id 0
BGP table version 13
RIB entries 23, using 4232 bytes of memory
Peers 3, using 2149 KiB of memory
Peer groups 2, using 128 bytes of memory

Neighbor                                     V         AS    LocalAS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
router0(net0)                                4      65000      65010       490       492        0    0    0 00:23:57            8       13 N/A
clab-bgp-cplane-demo-control-plane(10.0.1.2) 4      65010      65010        28        34        0    0    0 00:01:17            1       11 N/A
clab-bgp-cplane-demo-worker(10.0.2.2)        4      65010      65010        27        33        0    0    0 00:01:14            1       11 N/A

Total number of neighbors 3
```

<u><b>Command (tor1):</b></u>
```bash
docker exec -it clab-bgp-cplane-demo-tor1 vtysh -c 'show bgp ipv4 summary wide'
```
<u><small>Output:</small></u>
```
IPv4 Unicast Summary (VRF default):
BGP router identifier 10.0.0.2, local AS number 65011 vrf-id 0
BGP table version 13
RIB entries 23, using 4232 bytes of memory
Peers 3, using 2149 KiB of memory
Peer groups 2, using 128 bytes of memory

Neighbor                               V         AS    LocalAS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
router0(net0)                          4      65000      65011       519       521        0    0    0 00:25:23            8       13 N/A
clab-bgp-cplane-demo-worker2(10.0.3.2) 4      65011      65011        57        64        0    0    0 00:02:43            1       11 N/A
clab-bgp-cplane-demo-worker3(10.0.4.2) 4      65011      65011        58        65        0    0    0 00:02:45            1       11 N/A

Total number of neighbors 3
```

## Deploying networking utility pods (netshoot)
Netshoot will be deployed using a DaemonSet. we will be using it to verify end-to-end connectivity later on.  
The daemonset can be found under [netshoot-ds.yaml](./netshoot-ds.yaml).  
The daemonset can be deployed with the following command:
<u><b>Command:</b></u>
```bash
kubectl apply -f netshoot-ds.yaml
kubectl rollout status daemonset netshoot -w
```
**Note:** At this point, the lab broke (so i'm not sure if the following works)  

## Test Connectivity with netshoot
To test the connectivity between the pods, we can use the `netshoot` pods.  
We can do this by running the following commands:  
<u><b>Command:</b></u>
```bash
# Get source pod
SRC_POD=$(kubectl get pods -o wide | grep "cplane-demo-worker " | awk '{ print($1); }')
# Get destination IP
DST_IP=$(kubectl get pods -o wide | grep worker3 | awk '{ print($6); }')
# Test connectivity
kubectl exec -it $SRC_POD -- ping $DST_IP
```
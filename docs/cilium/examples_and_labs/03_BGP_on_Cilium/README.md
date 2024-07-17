# BGP is a Data Center Standard
BGP is not just the foundational protocol behind the Internet; it is now the standard within data centers.  
Modern data center network fabrics are typically based on a “leaf-and-spine” architecture where BGP is typically used to propagate endpoint reachability information.  


## Table of Contents
- [BGP is a Data Center Standard](#bgp-is-a-data-center-standard)
  - [Table of Contents](#table-of-contents)
  - [BGP Support in Cilium](#bgp-support-in-cilium)
  - [The kind cluster](#the-kind-cluster)
  - [The Cilium BGP feature](#the-cilium-bgp-feature)

## BGP Support in Cilium
BGP support was initially introduced in Cilium 1.10 and subsequent improvements have been made since.  
A great example of the speed at which they're working is the recent introduction of IPv6 support in Cilium 1.12.

## The kind cluster
The kind cluster config can be found under the [kind_clusterconfig.yaml](./kind_clusterconfig.yaml) file.  
This config leaves us with the following:  
<u><small>Output:</small></u>
```
NAME                                 STATUS     ROLES           AGE    VERSION
clab-bgp-cplane-demo-control-plane   NotReady   control-plane   2m2s   v1.29.2
clab-bgp-cplane-demo-worker          NotReady   <none>          99s    v1.29.2
clab-bgp-cplane-demo-worker2         NotReady   <none>          100s   v1.29.2
clab-bgp-cplane-demo-worker3         NotReady   <none>          99s    v1.29.2
```
We can see that the cluster is NotReady, which is the expected behavior since we haven't deployed Cilium yet. 

##  The Cilium BGP feature
To showcase the Cilium BGP feature, we need a BGP-capable device to peer with.  
For this purpose, we will be leveraging Containerlab and FRR (Free Range Routing). These great tools provide the ability to simulate networking environment in containers.  
[Containerlab](https://containerlab.srlinux.dev/) is a container-based tool that allows you to define and deploy complex networking labs with a single command.  
[FRRouting](https://frrouting.org/) is an IP routing protocol suite for Linux and Unix platforms which includes protocol daemons for BGP, IS-IS, LDP, OSPF, PIM, and RIP.  
The network overview:  
![Network Overview](./bgp_overview.png)  

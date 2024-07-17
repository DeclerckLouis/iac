# Deploying the network
## Table of Contents
- [Deploying the network](#deploying-the-network)
  - [Table of Contents](#table-of-contents)
  - [Inspect the topology](#inspect-the-topology)
  - [Deploy the topology](#deploy-the-topology)

## Inspect the topology
The topology for this lab can be found in the [topo.yaml](./topo.yaml) file.  
The main thing to note is that there are 3 main routing nodes:  
- A backbne router (router0)
- Two TOR (Top Of Rack) routers (tor0 and tor1)  
At the end of the file you can also see that we're establishing a virtual link between the TOR routers.  
<u><b>Topology:</b></u>  
![Topology](./bgp_topo.png)

## Deploy the topology
To deploy the topology, we can use the following command:  
<u><b>Command:</b></u>  
```bash
containerlab -t ./topo.yaml deploy
```
**Note:** The deployment will take a few minutes to complete.  
<u><small>Output:</small></u>  
```
INFO[0000] Containerlab v0.31.1 started                 
INFO[0000] Parsing & checking topology file: topo.yaml  
INFO[0000] Creating lab directory: /root/clab-bgp-cplane-demo 
INFO[0000] Creating docker network: Name="clab", IPv4Subnet="172.20.20.0/24", IPv6Subnet="2001:172:20:20::/64", MTU="1500" 
INFO[0000] Creating container: "router0"                
INFO[0000] Creating container: "tor1"                   
INFO[0000] Creating container: "tor0"                   
INFO[0000] Creating container: "srv-worker2"            
INFO[0000] Creating container: "srv-worker3"            
INFO[0000] Creating container: "srv-control-plane"      
INFO[0000] Creating container: "srv-worker"             
INFO[0000] Creating virtual wire: tor1:net1 <--> srv-worker2:net0 
INFO[0000] Creating virtual wire: tor1:net2 <--> srv-worker3:net0 
INFO[0000] Creating virtual wire: tor0:net1 <--> srv-control-plane:net0 
INFO[0000] Creating virtual wire: tor0:net2 <--> srv-worker:net0 
INFO[0000] Creating virtual wire: router0:net1 <--> tor1:net0 
INFO[0000] Creating virtual wire: router0:net0 <--> tor0:net0 
INFO[0000] Adding containerlab host entries to /etc/hosts file 
INFO[0001] Executed command '/usr/lib/frr/frrinit.sh start' on clab-bgp-cplane-demo-tor1. stdout:
Started watchfrr 
INFO[0001] Executed command '/usr/lib/frr/frrinit.sh start' on clab-bgp-cplane-demo-router0. stdout:
Started watchfrr 
INFO[0001] Executed command '/usr/lib/frr/frrinit.sh start' on clab-bgp-cplane-demo-tor0. stdout:
Started watchfrr 
INFO[0001] 🎉 New containerlab version 0.56.0 is available! Release notes: https://containerlab.dev/rn/0.56/
Run 'containerlab version upgrade' to upgrade or go check other installation options at https://containerlab.dev/install/ 
+---+----------------------------------------+--------------+--------------------------+-------+---------+----------------+----------------------+
| # |                  Name                  | Container ID |          Image           | Kind  |  State  |  IPv4 Address  |     IPv6 Address     |
+---+----------------------------------------+--------------+--------------------------+-------+---------+----------------+----------------------+
| 1 | clab-bgp-cplane-demo-router0           | 485267782b3a | frrouting/frr:v8.2.2     | linux | running | 172.20.20.4/24 | 2001:172:20:20::4/64 |
| 2 | clab-bgp-cplane-demo-srv-control-plane | 9585d3b2a7ec | nicolaka/netshoot:latest | linux | running | N/A            | N/A                  |
| 3 | clab-bgp-cplane-demo-srv-worker        | ac77aa33265a | nicolaka/netshoot:latest | linux | running | N/A            | N/A                  |
| 4 | clab-bgp-cplane-demo-srv-worker2       | 0ef3d2da5bb5 | nicolaka/netshoot:latest | linux | running | N/A            | N/A                  |
| 5 | clab-bgp-cplane-demo-srv-worker3       | c1a5720c86c2 | nicolaka/netshoot:latest | linux | running | N/A            | N/A                  |
| 6 | clab-bgp-cplane-demo-tor0              | 259ad7ed29b9 | frrouting/frr:v8.2.2     | linux | running | 172.20.20.3/24 | 2001:172:20:20::3/64 |
| 7 | clab-bgp-cplane-demo-tor1              | bd792ec738f8 | frrouting/frr:v8.2.2     | linux | running | 172.20.20.2/24 | 2001:172:20:20::2/64 |
+---+----------------------------------------+--------------+--------------------------+-------+---------+----------------+----------------------+
```
To verifiy that BGP is up between the TOR routers and the backbone (core) router, you can run the following command:  
<u><b>Command:</b></u>  
```bash
docker exec -it clab-bgp-cplane-demo-router0 vtysh -c 'show bgp ipv4 summary wide'
```
This command does the following:  
- `docker exec -it clab-bgp-cplane-demo-router0` - Execute a command in the `router0` container
- `vtysh` - Start the FRRouting VTY shell
- `-c 'show bgp ipv4 summary wide'` - Run the `show bgp ipv4 summary wide` command to display the BGP summary

The output should look like this:  
<u><small>Output:</small></u>  
```
IPv4 Unicast Summary (VRF default):
BGP router identifier 10.0.0.0, local AS number 65000 vrf-id 0
BGP table version 8
RIB entries 15, using 2760 bytes of memory
Peers 2, using 1433 KiB of memory
Peer groups 1, using 64 bytes of memory

Neighbor        V         AS    LocalAS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
tor0(net0)      4      65010      65000        29        28        0    0    0 00:01:02            3        9 N/A
tor1(net1)      4      65011      65000        29        28        0    0    0 00:01:01            3        9 N/A

Total number of neighbors 2
```

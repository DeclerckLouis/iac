# Deploying the network
## Table of Contents
- [Deploying the network](#deploying-the-network)
  - [Table of Contents](#table-of-contents)
  - [Inspect the topology](#inspect-the-topology)

## Inspect the topology
The topology for this lab can be found in the [topo.yaml](./topo.yaml) file.  
The main thing to note is that there are 3 main routing nodes:  
- A backbne router (router0)
- Two TOR (Top Of Rack) routers (tor0 and tor1)  
At the end of the file you can also see that we're establishing a virtual link between the TOR routers.  
<u><b>Topology:</b></u>  
![Topology](./bgp_topo.png)

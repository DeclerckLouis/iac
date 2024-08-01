# Installation
## Getting started
### First Installation
To setup the project on your local machine, follow these steps:
| **This has only been tested on a rpi5 running Ubuntu Server 22.04 and 24.04** |
1. Clone the repository
2. run the bootstrap.sh script `sudo bash iac/scripts/bootstrap.sh`  

### Kubernetes
At the moment, i'm running k3s on a single raspberry pi 4 that's running Ubuntu Server 22.04.
K3s is a lightweight kubernetes distribution that's designed for edge computing. It's a single binary that's easy to install and manage.
The following modifications were made to the k3s installation:
- The k3s token was generated and saved in the home directory (to easily join other nodes to the cluster later).
- The flannel backend was set to none. This is because i'm using cilium as the CNI plugin.
- Network policies were disabled. This is because cilium has it's own network policies.
- The kubeconfig file was set to be readable by all users. **This is a security risk**.  It's only done for the sake of simplicity.  
  In a production environment, the kubeconfig file should be readable only by the user that's running the k3s service.

#### RPI Network Configuration
The network configuration for the rpi4 is as follows:
```yaml
network:
  ethernets:
    eth0:
      dhcp4: false
      addresses: [your_static_ip/24]
      routes: 
        - to: default
          via:   your_gateway
      nameservers:
        addresses: [your_dns]
  version: 2
```
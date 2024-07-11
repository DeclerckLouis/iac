# Installation
## Getting started
### First Installation
To setup the project on your local machine, follow these steps:
| **This has only been tested on a rpi4 running Ubuntu Server 22.04** |
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

#### Installing k3s
To install k3s, run the following command:
```bash
openssl rand -hex 16 > k3s_token.txt
curl -sfL https://get.k3s.io | K3s_token=$(cat k3s_token.txt) sh -s - --cluster-init --write-kubeconfig-mode 644 --flannel-backend=none --disable-network-policy
```

#### Install cilium
This installation is taken from [the cilium documentation](https://docs.cilium.io/en/stable/installation/k3s/).  
To install cilium, run the following commands:
```bash
# Download cilium cli
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}

# Install cilium
cilium install --version 1.15.6 --set=ipam.operator.clusterPoolIPv4PodCIDRList="10.42.0.0/16"
```
# Helper scripts
This directory contains helper scripts that can be used to automate the setup of the project.  

## bootstrap.sh
### General
This script will download and install helm, k3s and cilium on a Raspberry Pi 4 running Ubuntu Server 22.04.
It requires a working network connection (preferably with a static IP address).  
After running the script, give the machine a bit of time to start all the services. (this can take up to 10 minutes).  

### Pre-requisites
**IMPORTANT**: Some pre-requisites are required (or recommended) before running the script:
- The machine should have a static IP address.  
- **At the moment, i haven't gotten it to work with more than 1 DNS server.**
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

- Swap should be disabled and Cgroup should be enabled.
```bash	
# Disable swap
sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab
# add the following line to /boot/firmware/cmdline.txt at the end:
# cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory
sudo nano /boot/firmware/cmdline.txt
sudo reboot now
```


### Usage
To run the script, execute the following commands on the Raspberry Pi:
```bash
sudo bash iac/scripts/bootstrap.sh
```

### Notes
- The script will install helm, k3s and cilium.
- The script will set the kubeconfig file to be readable by all users. **This is a security risk**.  It's only done for the sake of simplicity.  
  In a production environment, the kubeconfig file should be readable only by the user that's running the k3s service.
- The script will generate a k3s token and save it in the home directory. This token can be used to join other nodes to the cluster.
- the script will ask for confirmation before proceeding with the installation


## argo-cd.sh
This script will install ArgoCD in the k3s cluster.
It requires a working k3s cluster with kubectl installed on the machine that's running the script.
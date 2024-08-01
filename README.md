# Deploying infrastructure as Code in Kubernetes
## Introduction
### What's this project about?
This repository contains all the code and documentation for deploying infrastructure as code on a Raspberry Pi 4 running Ubuntu Server 22.04.
It's a personal project that i'm working on to learn more about Kubernetes, Terraform, Ansible, and other DevOps / SRE tools. 

### ToDos
- [x] Add a script to install k3s and cilium
- [x] Add a script to install helm
- [x] Add a script to install ArgoCD
- [ ] Add playbooks for further kubernetes configuration 
- [ ] Make joining worker nodes easier and more secure

### What is used in this project
Currently, the following tools are used in this project:
- [Terraform](https://www.terraform.io/)
- [Ansible](https://www.ansible.com/)
- [Kubernetes](https://kubernetes.io/)
- [Cilium](https://cilium.io/)

## Setup Procedure
### First Installation
To setup the project on your local machine (rpi4 running Ubuntu Server 22.04), there is a bootstrap.sh script in the [scripts directory](./scripts).  
This script will install ansible, and then run the ansible playbooks to configure the machine.
To have an automated setup, run the following commands:
```bash
sudo apt-get update
sudo apt-get install -y git
git clone https://github.com/DeclerckLouis/iac
sudo bash iac/scripts/bootstrap.sh
```

### Add worker nodes
Running bootstrap.sh without extra arguments will install k3s and cilium on the machine.  
It will also save the kubeconfig file under `~/.kube/config`.  
The k3s_token is also saved under `~/.kube/k3s_token`. (Remember to delete this file after adding the worker nodes)  
Now, to join a worker node, clone this repo on the worker node and run the following command:
```bash
sudo bash iac/scripts/bootstrap.sh -w
```
You will be asked to provide a Cluster IP and the k3s_token.  
Please refer to the [docs directory](./docs) for further installation instructions.

### Resources
A list of resources that contain useful information about the tools used in this project:
- [Terraform](https://www.terraform.io/)
- [Ansible](https://www.ansible.com/)
- [Kubernetes](https://kubernetes.io/)
- [K3s](https://k3s.io/)
- [Cilium](https://cilium.io/)
- [Helm](https://helm.sh/)
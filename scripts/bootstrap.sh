#!/bin/bash

# This script will install ansible and run the maser-node.yaml playbook on the local machine.
# This script is intended to be run on the master node.
# It has only been tested on a raspberry pi 4 running ubuntu 22.04.

# Test user
user_type=$(whoami)
if [ $user_type == "root" ]; then
    clear
    echo "User is root. Proceeding with installation."
else
    echo "Please run this script as root."
    exit 1
fi

# Apt update 
echo "Updating package list..."
apt-get -y update > /dev/null
echo "Done."
echo ""

# Install Python
echo "Installing python..."
apt-get -y install python3 > /dev/null
echo "Done."
echo ""

# Install pip
echo "Installing python3-pip..."
apt-get -y install python3-pip > /dev/null
echo "Done."
echo ""

# Install Docker
# Install Docker requirements
echo "Installing Docker"
apt-get -y install apt-transport-https ca-certificates curl software-properties-common > /dev/null
echo "Docker requirements installed."
echo ""

# Get Docker repo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - > /dev/null
add-apt-repository "deb [arch=arm64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /dev/null
echo "Docker repo added."

# Update package list and install full Docker suite
apt-get -y update > /dev/null
apt-get -y install docker-* > /dev/null
echo "Docker installed."
echo "Done."
echo ""

# Pull Ansible Docker image
echo "Pulling Ansible Docker image..."
docker pull cytopia/ansible:latest
echo "Done."
echo ""

# Run Ansible playbook using Docker
echo "Running Ansible playbook using Docker..."
# This command mounts the ansible directory in the current directory to the /ansible directory in the container.
# It also mounts the k3s and kube directories to the container.
# The playbook is then run using the bootstrap.yaml playbook and the bootstrap inventory file.
docker run --rm -v $(pwd)/ansible:/ansible -v /etc/rancher/k3s:/etc/rancher/k3s -v ~/.kube:/root/.kube cytopia/ansible:latest ansible-playbook /ansible/playbooks/bootstrap.yaml -i /ansible/inventories/bootstrap.yaml
echo "Done."



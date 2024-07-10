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

# Install required packages
echo "Installing required packages..."
apt-get -y install curl openssl > /dev/null
echo "Done."
echo ""

# Generate the k3s token and save it 
echo "Generating k3s token..."
k3s_token_value=$(openssl rand -hex 16) 
echo $k3s_token_value > $(pwd)/k3s_token.txt
echo "Done."
echo ""

# Install k3s
echo "Setting up kubernetes..."
curl -sfL https://get.k3s.io | K3s_token=$k3s_token_value sh -s - --cluster-init --write-kubeconfig-mode 644 --flannel-backend=none --disable-network-policy 
echo "K3s installed."

# Add kubeconfig to user home dir
echo "Copying kubeconfig"
cp /etc/rancher/k3s/k3s.yaml /home/${USER}/.kube/config
echo "Kubeconfig copied."
echo ""

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

echo "Waiting for node to be ready..."
echo "This may take a few minutes."
# grepping for nodes that are either at the Ready or NotReady state (it will never be Ready without a CNI )
while [ $(kubectl get nodes | grep -c "Ready") -lt 1 ]; do
    sleep 5
    echo "."
done
echo "Node is responding."
echo ""

echo "Installing Cilium..."
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=arm64
echo "Variables set."

curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
echo "Cilium CLI installed."

# Install cilium
echo "Installing cilium..."
cilium install --version 1.15.6 --set=ipam.operator.clusterPoolIPv4PodCIDRList="10.42.0.0/16"
echo "Done."
echo ""
echo "Please give the node up to 10 minutes to be ready. "
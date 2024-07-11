#!/bin/bash

# This script will install k3s and cilium on a single node cluster.
# This script is intended to be run on the master node.
# It has only been tested on a raspberry pi 4 running ubuntu 22.04.

# Set some base variables
USER_HOME=$(eval echo ~${SUDO_USER})
IP_ADDRESS=$(hostname -I | cut -d ' ' -f 1)


# Test user
if [ $USER == "root" ]; then
    clear
    echo "User is ${SUDO_USER} with Admin rights. Running as ${USER}"
    echo "Kubeconfig and token will be saved to ${USER_HOME}."
    echo "IP Address is ${IP_ADDRESS}"
else
    echo "Please run this script as root."
    exit 1
fi

# Ask user if they want to proceed
read -p "Do you want to proceed with the installation? (y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Exiting."
    exit 1
fi

# Check for apt lock files
if lsof /var/lib/apt/lists/lock /var/cache/apt/archives/lock /var/lib/dpkg/lock > /dev/null 2>&1; then
    echo "apt is busy. Please try again later."
    exit 1
fi

echo "Proceeding with installation..."
# Apt update 
echo "Updating package list..."
apt-get -y update > /dev/null
echo "Done."
echo ""

# Install required packages
echo "Installing required packages..."
apt-get -y install curl openssl > /dev/null
echo "Apt packages installed."

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
echo "Helm installed."

echo "Done."
echo ""

mkdir ${USER_HOME}/.kube

# Generate the k3s token 
echo "Generating k3s token..."
k3s_token_value=$(openssl rand -hex 16)
echo "Token generated." 
echo "Token will be saved to ${USER_HOME}/k3s_token.txt" after k3s installation.
echo "Done."
echo ""

# Install k3s
echo "Setting up kubernetes..."
curl -sfL https://get.k3s.io | K3s_token=$k3s_token_value sh -s - --cluster-init --write-kubeconfig-mode 644 --flannel-backend=none --disable-network-policy 
echo "K3s installed."

# Save the k3s token to the user home directory
echo $k3s_token_value > ${USER_HOME}/.kube/k3s_token.txt
echo "Token saved to ${USER_HOME}/.kube/k3s_token.txt."

# Add kubeconfig to user home dir
cp /etc/rancher/k3s/k3s.yaml ${USER_HOME}/.kube/config
echo "Kubeconfig copied to home directory of ${SUDO_USER}."

echo "Waiting for node to be ready..."
echo "This may take a few minutes."
sleep 10
# grepping for nodes that are either at the Ready or NotReady state (it will never be Ready without a CNI )
while [ $(kubectl get nodes | grep -c "Ready") -lt 1 ]; do
    sleep 5
    echo "."
done
echo "Node is responding."
echo "Done."
echo ""


echo "Installing Cilium..."
# Set kubeconfig for cilium installation
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=arm64
echo "Variables set."

curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum 
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
echo "Cilium CLI installed."

# Install cilium
cilium install --version 1.15.6 --set=ipam.operator.clusterPoolIPv4PodCIDRList="10.42.0.0/16"
echo "Cilium installed."

# # enable hubble -> you must install the hubble client on your local machine to use this feature
# # https://docs.cilium.io/en/latest/gettingstarted/hubble_setup/#hubble-setup
# echo "Enabling Hubble..."
# cilium hubble enable --ui
# while [ $(kubectl get pods -n kube-system | grep -c "cilium-hubble") -lt 1 ]; do
#     sleep 5
#     echo "."
# done
# echo "Hubble enabled."

# # Port forward hubble ui
# kubectl port-forward -n kube-system svc/hubble-ui --address 127.0.0.1 12000:80
# echo "Hubble UI port forwarded to localhost:12000."

echo "Done."
echo ""
echo "Please give the node up to 10 minutes to be ready. "
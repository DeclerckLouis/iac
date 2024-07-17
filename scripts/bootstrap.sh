#!/bin/bash

# This script will install k3s and cilium on a single node cluster.
# This script is intended to be run on the master node.
# It has only been tested on a raspberry pi 4 running ubuntu 22.04.

############################################ VARIABLES & FUNCTIONS ############################################

# Set some base variables
USER_HOME=$(eval echo ~${SUDO_USER})
IP_ADDRESS=$(hostname -I | cut -d ' ' -f 1)

SKIP_CONFIRMATION=false
INSTALL_HUBBLE=false
INSTALL_ARGO=false

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -y)
      SKIP_CONFIRMATION=true
      ;;
    --hubble)
      INSTALL_HUBBLE=true
      ;;
    --argo)
      INSTALL_ARGO=true
      ;;
    *)
      echo "Usage: bash bootstrap.sh [-y] [--hubble] [--ARGO]"
      echo "Options:"
      echo "  -y        Skip confirmation"
      echo "  --hubble  Install Hubble"
      echo "  --argo    Install Argo"
      exit 1
      ;;
  esac
  shift
done


# a confirmation function
ask_confirmation() {
    if [ "$SKIP_CONFIRMATION" = false ]; then
        echo ""
        read -p "Press [ENTER] to continue or Ctrl-c to cancel."
        echo ""
    fi
}

############################################ CHECKS ############################################

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
ask_confirmation

# Check for apt lock files
if lsof /var/lib/apt/lists/lock /var/cache/apt/archives/lock /var/lib/dpkg/lock > /dev/null 2>&1; then
    echo "apt is busy. Please try again later."
    exit 1
fi

# Create .kube dir in user home if it doesn't exist
echo "Creating kube directory in ${USER_HOME}..."
if [ ! -d "${USER_HOME}/.kube" ]; then
    mkdir ${USER_HOME}/.kube
    chown -R ${SUDO_USER}:${SUDO_USER} ${USER_HOME}/.kube
    chmod 755 ${USER_HOME}/.kube
    echo "Directory created."
else
    echo "Directory already exists."
fi
echo "Done."
echo ""

############################################ DEPENDENCIES ############################################

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

echo ""
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
echo "Helm installed."

echo "Done."
echo ""


############################################ K3S ############################################

# Generate the k3s token 
echo "Generating k3s token..."
k3s_token_value=$(openssl rand -hex 16)
echo "Token generated." 
echo "Token will be saved to ${USER_HOME}/k3s_token.txt" after k3s installation.
echo "Done."
echo ""

# Install k3s
echo "Setting up kubernetes..."
curl -sfL https://get.k3s.io | K3s_token=$k3s_token_value sh -s - \
    --write-kubeconfig-mode 644 \
    --flannel-backend=none \
    --disable-kube-proxy \
    --disable servicelb \
    --disable-network-policy \
    --disable=traefik \
    --cluster-init

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
    sleep 10
    echo "."
done
echo "Node is responding."
echo "Done."
echo ""

############################################ CILIUM ############################################

echo "Installing Cilium..."
# Set kubeconfig for cilium installation
# The following can be done with helm charts as well
# helm repo add cilium https://helm.cilium.io/
# helm repo update
# helm install cilium cilium/cilium
# helm upgrade cilium cilium/cilium
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
echo "Variables set."

#Download
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
# Check sha256sum
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
# Unpack in /usr/local/bin and remove the tarball
tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
echo "Cilium CLI installed."

# Install cilium 
# CURRENT CILIUM VERSION: 1.15.7 -> SEE GITHUB RELEASES https://github.com/cilium/cilium/releases
cilium install \
  --version 1.15.7 \
  --set k8sServiceHost=${IP_ADDRESS} \
  --set k8sServicePort=6443 \
  --set kubeProxyReplacement=true \
  --set=ipam.operator.clusterPoolIPv4PodCIDRList="10.42.0.0/16"
echo "Cilium installed."
echo "Done."

############################################ HUBBLE ############################################

if [ "$INSTALL_HUBBLE" = true ]; then
  # enable hubble -> you must install the hubble client on your local machine to use this feature
  # https://docs.cilium.io/en/latest/gettingstarted/hubble_setup/#hubble-setup
  echo "Enabling Hubble..."
  cilium hubble enable --ui
  while [ $(kubectl get pods -n kube-system | grep -c "hubble-ui") -lt 1 ]; do
      sleep 5
      echo "."
  done
  echo "Hubble enabled."

  # Install hubble cli
  HUBBLE_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/hubble/master/stable.txt)
  HUBBLE_ARCH=amd64
  if [ "$(uname -m)" = "aarch64" ]; then HUBBLE_ARCH=arm64; fi
  curl -L --fail --remote-name-all https://github.com/cilium/hubble/releases/download/$HUBBLE_VERSION/hubble-linux-${HUBBLE_ARCH}.tar.gz{,.sha256sum}
  sha256sum --check hubble-linux-${HUBBLE_ARCH}.tar.gz.sha256sum
  sudo tar xzvfC hubble-linux-${HUBBLE_ARCH}.tar.gz /usr/local/bin
  rm hubble-linux-${HUBBLE_ARCH}.tar.gz{,.sha256sum}
  echo "Hubble CLI installed."

  cilium hubble port-forward &
  echo "Hubble port-forwarded."
  echo "Done."

    fi

############################################ ARGO ############################################

if [ "$INSTALL_ARGO" = true ]; then
  # Install argo-cd
  bash ./argo-cd.sh

echo ""
echo "Please give the node up to 10 minutes to be ready. "
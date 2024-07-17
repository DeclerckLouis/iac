#!/bin/bash

# This script will install argo-cd on a k3s cluster
# It has only been tested on a raspberry pi 4 running ubuntu 22.04.

# Set homedir variable based on user
if [ $USER == "root" ]; then
    HOMEDIR=$(eval echo ~${SUDO_USER})
else
    HOMEDIR=$(eval echo ~${USER})
fi

ARGO_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then ARGO_ARCH=arm64; fi

clear

echo "Installing argoCD CLI..."
curl -sLO https://github.com/argoproj/argo-workflows/releases/download/v3.5.8/argo-linux-${ARGO_ARCH}.gz
gunzip argo-linux-${ARGO_ARCH}.gz
chmod +x argo-linux-${ARGO_ARCH}
mv ./argo-linux-${ARGO_ARCH} /usr/local/bin/argo

echo "Installing Argo CD on k3s cluster..."
echo "Argo CD initial password will be saved to ${HOMEDIR}/argocd_password.txt"
sleep 1

# Create a namespace for argo-cd
kubectl create namespace argocd

# Apply the argo-cd manifests
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for argo-cd to be ready
echo ""
echo "Waiting for Argo CD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd > /dev/null

# Patch the argo-cd service to use NodePort
echo "Patching Argo CD service to use NodePort..."
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}' > /dev/null

# Get the networking information
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
NODE_PORT=$(kubectl get svc -n argocd argocd-server -o jsonpath="{.spec.ports[?(@.name=='https')].nodePort}")

# Restart the argocd server pod
echo "Restarting Argo CD server pod to appply changes..."
kubectl -n argocd delete pod -l app.kubernetes.io/name=argocd-server > /dev/null
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd > /dev/null
echo ""
echo "Argo CD is ready."

# Get the inital password
ARGOCDSECRET=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d) 
echo "$ARGOCDSECRET" > ${HOMEDIR}/argocd_password.txt
echo "Done."

echo ""
echo ""
echo "You can now log in to Argo CD at https://${NODE_IP}:${NODE_PORT}"
echo "The user credentials are as follows: "
echo "Username: admin"
echo "Password: $ARGOCDSECRET"
echo "Bye."

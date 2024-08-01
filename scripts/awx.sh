#!/bin/bash

git clone https://github.com/ansible/awx-operator.git
cd awx-operator
git checkout tags/2.19.1

cat <<EOF > kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  # Find the latest tag here: https://github.com/ansible/awx-operator/releases
  - github.com/ansible/awx-operator/config/default?ref=2.19.1
# Set the image tags to match the git version from above
images:
  - name: quay.io/ansible/awx-operator
    newTag: 2.19.1

# Specify a custom namespace in which to install AWX
namespace: awx
EOF

kubectl apply -k .
echo "wait 15 seconds"
sleep 15
kubectl config set-context --current --namespace=awx

cat <<EOF > awx.yaml
apiVersion: awx.ansible.com/v1beta1
kind: AWX
metadata:
  name: awx-louis
spec:
  service_type: nodeport
EOF

cat <<EOF > kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  # Find the latest tag here: https://github.com/ansible/awx-operator/releases
  - github.com/ansible/awx-operator/config/default?ref=2.19.1
  - awx.yaml
# Set the image tags to match the git version from above
images:
  - name: quay.io/ansible/awx-operator
    newTag: 2.19.1

# Specify a custom namespace in which to install AWX
namespace: awx
EOF

kubectl apply -k . 
kubectl logs -f deployments/awx-operator-controller-manager -c awx-manager

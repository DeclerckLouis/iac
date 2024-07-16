# Cilium Installation
## Installation on kind
To install Cilium on a [kind cluster](https://kind.sigs.k8s.io/), you can follow the [official documentation](https://docs.cilium.io/en/stable/gettingstarted/kind/).
Or just do the following:  
### 1. Install cilium CLI
<u><b>Command:</b></u>
```bash
# Variables
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi

#Download
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
# Check sha256sum
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
# Unpack in /usr/local/bin and remove the tarball
tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
```

### 2. Install Cilium
<u><b>Command:</b></u>
```bash
cilium install
```
<u><small>Output:</small></u> 
```bash
🔮 Auto-detected Kubernetes kind: kind
✨ Running "kind" validation checks
✅ Detected kind version "0.22.0"
ℹ️  Using Cilium version 1.15.5
🔮 Auto-detected cluster name: kind-kind
ℹ️  Detecting real Kubernetes API server addr and port on Kind
🔮 Auto-detected kube-proxy has not been installed
ℹ️  Cilium will fully replace all functionalities of kube-proxy
```

### 3. Check the cilium status
<u><b>Command:</b></u>
```bash
cilium status --wait
```
<u><small>Output:</small></u> 
```bash
    /¯¯\
 /¯¯\__/¯¯\    Cilium:             OK
 \__/¯¯\__/    Operator:           OK
 /¯¯\__/¯¯\    Envoy DaemonSet:    disabled (using embedded mode)
 \__/¯¯\__/    Hubble Relay:       disabled
    \__/       ClusterMesh:        disabled

Deployment             cilium-operator    Desired: 1, Ready: 1/1, Available: 1/1
DaemonSet              cilium             Desired: 3, Ready: 3/3, Available: 3/3
Containers:            cilium             Running: 3
                       cilium-operator    Running: 1
Cluster Pods:          3/3 managed by Cilium
Helm chart version:    
Image versions         cilium             quay.io/cilium/cilium:v1.15.5@sha256:4ce1666a73815101ec9a4d360af6c5b7f1193ab00d89b7124f8505dee147ca40: 3
                       cilium-operator    quay.io/cilium/operator-generic:v1.15.5@sha256:f5d3d19754074ca052be6aac5d1ffb1de1eb5f2d947222b5f10f6d97ad4383e8: 1
```
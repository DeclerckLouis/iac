# Tetragon
**Tetragon doesn't seem to work (yet) on raspberry pi unless you recompile the kernel**  


## Table of Contents
- [Tetragon](#tetragon)
  - [Table of Contents](#table-of-contents)
  - [What is Tetragon?](#what-is-tetragon)
  - [Installation](#installation)
    - [With helm charts](#with-helm-charts)
  - [Usage](#usage)

## What is Tetragon?
From the [Tetragon docs](https://tetragon.io/docs/overview/)
Cilium Tetragon component enables powerful realtime, eBPF-based Security Observability and Runtime Enforcement.  
Tetragon detects and is able to react to security-significant events, such as:  
- Process execution events
- System call activity
- I/O activity including network & file access
When used in a Kubernetes environment, Tetragon is Kubernetes-aware - that is, it understands Kubernetes identities such as namespaces,  
pods and so-on. So that security event detection can be configured in relation to individual workloads.  

## Installation
### With helm charts
<u><b>Command:</b></u>  
```bash
helm repo add cilium https://helm.cilium.io
helm repo update
helm install tetragon cilium/tetragon -n kube-system
```

## Usage
Once installed, Tetragon can be used to detect and react to security-significant events.  
Some examples are:  
- Detecting a process execution event in a pod:  
`kubectl exec -ti -n kube-system ds/tetragon -c tetragon -- tetra getevents -o compact --pods PODTOMONITOR`
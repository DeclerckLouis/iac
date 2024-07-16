# Cilium
Cilium is a CNI plugin that brings API-aware networking and security filtering to containers running in Kubernetes.  
Cilium is built on top of eBPF, a new feature in the Linux kernel that makes it possible to run sandboxed programs inside a Linux kernel.  
eBPF is used to implement custom networking protocols, security filtering, and more.

## Why learn it?
Since Cilium is built on top of eBPF, it is able to provide a level of security and networking that is not possible with other CNI plugins.
Some of the features that Cilium provides include:
- Layer 7 (application) load balancing
- Layer 7 (application) security filtering
- Layer 3/4 (network) security filtering
- Network policy enforcement (similar to Calico)
- Hubble observability (similar to Istio)
- ...

## Getting Started
Following along with [this lab](https://isovalent.com/labs/getting-started-with-cilium/), you can learn some of the basics of Cilium.  
You can also check out the [official documentation](https://docs.cilium.io/en/stable/) for more information.  
in the [examples](./examples/) directory, you can find some example configurations of the above features.

## Installation
For more information about installing Cilium on a k3s cluster, check out the following resources:
- [the bootstrap script](../scripts/bootstrap.sh)
- [the official documentation](https://docs.cilium.io/en/stable/gettingstarted/k3s/)
- [this stonegarden article](https://blog.stonegarden.dev/articles/2024/02/bootstrapping-k3s-with-cilium/)
- 

## Further Reading
- [Cilium GitHub](https://github.com/cilium/cilium)
- [Cilium Documentation](https://docs.cilium.io/en/stable/)
- [What is eBPF?](https://ebpf.io/)
- [kubernetes](https://kubernetes.io/)
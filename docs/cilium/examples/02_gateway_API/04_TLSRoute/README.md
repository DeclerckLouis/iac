# TLSRoute
In the previous task, we looked at the `TLS Termination` and how the Gateway can terminate HTTPS traffic from a client and route the unencrypted HTTP traffic based on HTTP properties, like path, method or headers.

In this task, we will look at a feature that was introduced in Cilium 1.14: `TLSRoute`. This resource lets you passthrough TLS traffic from the client all the way to the Pods - meaning the traffic is encrypted end-to-end.

##
# Setup Cluster Mesh

KKP Docu: [Cilium Cluster Mesh Setup
](https://docs.kubermatic.com/kubermatic/v2.27/tutorials-howtos/networking/cilium-cluster-mesh/)

## Cluster 1

Setup regular Cluster with Cilium, ether modify the values via KKP UI or do via the make:

TODO UPDATE
```yaml
cluster:
  name: cluster-1
  id: 1
clustermesh:
  useAPIServer: true
  config:
    enabled: true
  apiserver:
    tls:
      auto:
        method: cronJob
    service:
      type: LoadBalancer
```

*IMPORTANT: Note you need to ensure that you have node-to-node connection and non overlapping IPs:*


# rejekts2025-glsb

Demo for the talk "Evaluating Global Load Balancing Options for Kubernetes in Practice" presented at Cloud Native Rejekts 2025 in London.

## Overview

TODO:

## Try it for yourself

### Prerequisites

- At least three Kubernetes clusters (we used [clusters managed by KKP](https://kubermatic.com/products/kubermatic-kubernetes-platform/)) with:
  - LoadBalancers that are reachable from each other and your local machine
- A public domain name hosted on a DNS provider that supports [external-dns](https://github.com/kubernetes-sigs/external-dns) (we used Cloudflare)
- Kubectl installed on your local machine
- Helm installed on your local machine
- Make installed on your local machine

### Setup your environment

1. Clone this repository:

   ```bash
   git clone git@github.com:nicolaiort/rejekts2025-glsb.git #via SSH
   # or
   git clone https://github.com/nicolaiort/rejekts2025-glsb.git #via HTTPS
   ```

2. Change into the directory:

   ```bash
   cd rejekts2025-glsb
   ```

3. Get your kubeconfigs for the clusters you want to use and place them in the `.secrets` directory.
   The files should be named `cluster1-kubeconfig`, `cluster2-kubeconfig`, etc.

4. Create secrets, create namespaces and install nginx with cert-manager into your clusters:

   ```bash
   make setup
   ```

### K8GB Demo

Setup k8gb in all clusters:

```bash
make k8gb-setup
```

#### Round Robin

1. Set your demo service to round-robin:

   ```bash
   make k8gb-roundrobin
   ```

2. Observe the responses of the demo service:

   ```bash
   make repeat TIMES=10 COMMAND="make curl-resolved DOMAIN=demo.k8gb.nig.gl"
   ```

   It should round-robin between the clusters.

3. Take down one of the clusters:

   ```bash
   make stop-service CLUSTERID=1
   ```

4. Observe the responses of the demo service:

   ```bash
   make repeat TIMES=10 COMMAND="make curl-resolved DOMAIN=demo.k8gb.nig.gl"
   ```

   It should round-robin between the clusters excluding the one we took down.

5. Bring the cluster back up:

   ```bash
   make start-service CLUSTERID=1
   ```

6. Observe the responses of the demo service:

   ```bash
   make repeat TIMES=10 COMMAND="make curl-resolved DOMAIN=demo.k8gb.nig.gl"
   ```

   It should round-robin between all clusters again.

#### Failover

1. Set your demo service to failover:

   ```bash
   make k8gb-failover
   ```

2. Observe the responses of the demo service:

   ```bash
   make repeat TIMES=10 COMMAND="make curl-resolved DOMAIN=demo.k8gb.nig.gl"
   ```

   It should always respond from the primary cluster.

3. Take down the primary cluster:

   ```bash
   make stop-service CLUSTERID=1
   ```

4. Observe the responses of the demo service:

   ```bash
   make repeat TIMES=10 COMMAND="make curl-resolved DOMAIN=demo.k8gb.nig.gl"
   ```

   It should now round-robin between the remaining clusters.

5. Bring the cluster back up:

   ```bash
   make start-service CLUSTERID=1
   ```

6. Observe the responses of the demo service:

   ```bash
   make repeat TIMES=10 COMMAND="make curl-resolved DOMAIN=demo.k8gb.nig.gl"
   ```

   It should always respond from the primary cluster.

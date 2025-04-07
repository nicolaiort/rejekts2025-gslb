# rejekts2025-gslb

Demo for the talk "Evaluating Global Load Balancing Options for Kubernetes in Practice" presented at [Cloud Native Rejekts 2025](https://cfp.cloud-native.rejekts.io/cloud-native-rejekts-europe-london-2025/talk/UFZNVH/) in London by [Nicolai Ort](https://github.com/nicolaiort) and [Tobias Schneck](https://github.com/toschneck).

## Overview

This repository contains two main demos:

1. **k8gb**: A demo of the [k8gb](https://k8gb.io/) global load balancer
  - Round Robin based load balancing across multiple clusters
  - Failover based load balancing across multiple clusters with one primary cluster and multiple secondary clusters
2. **clustermesh**: A demo of clustermesh based load balancing implemented with [cilium](https://cilium.io/)

We also included the drawings we used in the talk to explain the concepts of global load balancing in the `images` directory. The `.excalidraw.svg` files are editable with [Excalidraw](https://excalidraw.com/).

## Try it for yourself

Please note that this repo contains secrets encrypted with [git-crypt](https://github.com/AGWA/git-crypt), they are only used for the live-demo and are not needed to run the demo yourself.
You can just override the secrets with your own values.

### Prerequisites

- Three Kubernetes clusters (we used [clusters managed by KKP](https://kubermatic.com/products/kubermatic-kubernetes-platform/)) with:
  - LoadBalancers that are reachable from each other and your local machine
  - LoadBalancers must support UDP (yes, some cloud providers don't support UDP for LoadBalancers)
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

### K8GB Demo

1. Switch to the `k8gb` directory:

   ```bash
   cd k8gb
   ```

2. Get your kubeconfigs for the clusters you want to use and place them in the `.secrets` directory.
   The files should be named `cluster1-kubeconfig`, `cluster2-kubeconfig`, etc.

3. Create secrets, create namespaces and install nginx with cert-manager into your clusters:

   ```bash
   make setup
   ```

4. Setup k8gb in your clusters:

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
   # or to just get the counts
   make dig-chart TIMES=100 DOMAIN="demo.k8gb.nig.gl"
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

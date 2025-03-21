# rejekts2025-glsb

Demo for the talk "Evaluating Global Load Balancing Options for Kubernetes in Practice" presented at Cloud Native Rejekts 2025 in London.

## Overview

TODO:

## Try it for yourself

### Prerequisites

- At least two Kubernetes clusters (we used [clusters managed by KKP](https://kubermatic.com/products/kubermatic-kubernetes-platform/)) with:
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

4. Install nginx and cert-manager into your clusters:

   ```bash
   make setup
   ```
SHELL := /bin/bash
MAKEFLAGS := --no-print-directory
KUBECONFIG1 := .secrets/cluster1-kubeconfig
KUBECONFIG2 := .secrets/cluster2-kubeconfig
KUBECONFIG3 := .secrets/cluster3-kubeconfig

DOMAIN := "demo.k8gb.nig.gl"

#region Setup

setup:
	make setup-baseline
	make setup-echo

setup-baseline:
	make setup-baseline-single CURRENT_KUBECONFIG=$(KUBECONFIG1)
	make setup-baseline-single CURRENT_KUBECONFIG=$(KUBECONFIG2)
	make setup-baseline-single CURRENT_KUBECONFIG=$(KUBECONFIG3)

setup-baseline-single:
	KUBECONFIG=$(CURRENT_KUBECONFIG) kubectl create namespace nginx --dry-run=client -o yaml | KUBECONFIG=$(CURRENT_KUBECONFIG) kubectl apply -f -
	KUBECONFIG=$(CURRENT_KUBECONFIG) kubectl create namespace cert-manager --dry-run=client -o yaml | KUBECONFIG=$(CURRENT_KUBECONFIG) kubectl apply -f -
	KUBECONFIG=$(CURRENT_KUBECONFIG) kubectl apply -k baseline/tools
	KUBECONFIG=$(CURRENT_KUBECONFIG) kubectl wait --for=condition=available --timeout=180s deployment/cert-manager-webhook -n cert-manager
	KUBECONFIG=$(CURRENT_KUBECONFIG) kubectl apply -f baseline/configs

setup-echo:
	KUBECONFIG=$(KUBECONFIG1) kubectl apply -f deployments/cluster1.yaml
	KUBECONFIG=$(KUBECONFIG2) kubectl apply -f deployments/cluster2.yaml
	KUBECONFIG=$(KUBECONFIG3) kubectl apply -f deployments/cluster3.yaml
#endregion Setup

#region k8gb

k8gb-setup:
	@echo "Setting up k8gb..."
	make k8gb-setup-single CURRENT_KUBECONFIG=$(KUBECONFIG1) CURRENT_VALUES=values/cluster1.yaml
	make k8gb-setup-single CURRENT_KUBECONFIG=$(KUBECONFIG2) CURRENT_VALUES=values/cluster2.yaml
	make k8gb-setup-single CURRENT_KUBECONFIG=$(KUBECONFIG3) CURRENT_VALUES=values/cluster3.yaml
	@echo "k8gb setup complete."

k8gb-setup-single:
	helm repo add k8gb https://www.k8gb.io
	KUBECONFIG=$(CURRENT_KUBECONFIG) kubectl create namespace k8gb --dry-run=client -o yaml | KUBECONFIG=$(CURRENT_KUBECONFIG) kubectl apply -f -
	KUBECONFIG=$(CURRENT_KUBECONFIG) kubectl apply -f .secrets/cloudflaretoken.yaml
	KUBECONFIG=$(CURRENT_KUBECONFIG) helm upgrade --install k8gb k8gb/k8gb --namespace k8gb --version 0.14.0 -f $(CURRENT_VALUES)

k8gb-roundrobin:
	@echo "Deploying k8gb roundrobin demo..."
	make k8gb-deployments CURRENT_KUBECONFIG=$(KUBECONFIG1) CURRENT_DEPLOYMENT=configs/roundrobin.yaml
	@echo "k8gb deployments complete."

k8gb-failover: k8gb-failover1

k8gb-failover1:
	@echo "Deploying k8gb failover demo..."
	make k8gb-deployments CURRENT_KUBECONFIG=$(KUBECONFIG1) CURRENT_DEPLOYMENT=configs/primary-1.yaml
	@echo "k8gb deployments complete."

k8gb-failover2:
	@echo "Deploying k8gb failover demo..."
	make k8gb-deployments CURRENT_KUBECONFIG=$(KUBECONFIG1) CURRENT_DEPLOYMENT=configs/primary-2.yaml
	@echo "k8gb deployments complete."

k8gb-failover3:
	@echo "Deploying k8gb failover demo..."
	make k8gb-deployments CURRENT_KUBECONFIG=$(KUBECONFIG1) CURRENT_DEPLOYMENT=configs/primary-3.yaml
	@echo "k8gb deployments complete."

k8gb-deployments:
	KUBECONFIG=$(KUBECONFIG1) kubectl apply -f $(CURRENT_DEPLOYMENT)
	KUBECONFIG=$(KUBECONFIG2) kubectl apply -f $(CURRENT_DEPLOYMENT)
	KUBECONFIG=$(KUBECONFIG3) kubectl apply -f $(CURRENT_DEPLOYMENT)

k8gb-teardown:
	KUBECONFIG=$(KUBECONFIG1) kubectl delete -f configs/roundrobin.yaml
	KUBECONFIG=$(KUBECONFIG2) kubectl delete -f configs/roundrobin.yaml
	KUBECONFIG=$(KUBECONFIG3) kubectl delete -f configs/roundrobin.yaml

#endregion k8gb

#region Helpers

dig:
	@dig $(DOMAIN) +short @34.105.166.131

watch-dig:
	@watch make dig DOMAIN=$(DOMAIN)

dig-first:
	@dig $(DOMAIN) +short @34.105.166.131 | head -1

dig-chart:
	@for i in {1..$(TIMES)}; do make dig-first DOMAIN=$(DOMAIN); done | sort | uniq -c | sort -nr

curl-resolved:
	@curl -s -k -H "Host: $(DOMAIN)" -H "Connection: close" http://$(shell dig $(DOMAIN) +short @34.105.166.131 | head -1 ) && echo

watch-curl-resolved:
	@watch make curl-resolved DOMAIN=$(DOMAIN)

curl-resolved-chart:
	@for i in {1..$(TIMES)}; do make curl-resolved DOMAIN=$(DOMAIN); done | sort | uniq -c | sort -nr

repeat:
	@for i in {1..$(TIMES)}; do printf \-;printf " "; $(COMMAND); done

infinity:
	@while true; do printf \-;printf " "; $(COMMAND); done

oha:
	docker run -it ghcr.io/nicolaiort/oha:latest -n 10000 http://$(DOMAIN)

watch-pods:
	@watch kubectl --kubeconfig=$(CURRENT_KUBECONFIG) get pods -n default

#region Kubernetes
stop-service:
	KUBECONFIG=$(KUBECONFIG$(CLUSTERID)) kubectl scale deployment echo-service --replicas=0

start-service:
	KUBECONFIG=$(KUBECONFIG$(CLUSTERID)) kubectl scale deployment echo-service --replicas=2

watch-nodes:
	@watch kubectl --kubeconfig=$(CURRENT_KUBECONFIG) get nodes

kill-workers:
	KUBECONFIG=$(KUBECONFIG$(CLUSTERID)) kubectl scale machinedeployment -n kube-system thirsty-tesla --replicas=0
	KUBECONFIG=$(KUBECONFIG$(CLUSTERID)) kubectl delete node -l beta.kubernetes.io/instance-type=t3.small --force --grace-period=0

#endregion Kubernetes
#endregion Helpers
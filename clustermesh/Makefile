SHELL := /bin/bash
MAKEFLAGS := --no-print-directory
KUBECONFIG1 ?= .secrets/cluster1-kubeconfig
KUBECONFIG2 ?= .secrets/cluster2-kubeconfig
KUBECONFIG3 ?= .secrets/cluster3-kubeconfig

#region Setup

setup:
	make setup-baseline
	make setup-echo

setup-baseline:
	make setup-baseline-single CURRENT_KUBECONFIG=$(KUBECONFIG1)
	#make setup-baseline-single CURRENT_KUBECONFIG=$(KUBECONFIG2)
	#make setup-baseline-single CURRENT_KUBECONFIG=$(KUBECONFIG3)

setup-baseline-single:
	KUBECONFIG=$(CURRENT_KUBECONFIG) kubectl apply -f baseline/
	KUBECONFIG=$(CURRENT_KUBECONFIG) kubectl apply -f .secrets/baseline/

############# SERVICE MESH SETUP
## Cluster 1
cilium-cluster-1-default:
	KUBECONFIG=$(KUBECONFIG1) kubectl apply -f cluster-1/default.cilium.1.14.yaml
cilium-cluster-1-step-1:
	KUBECONFIG=$(KUBECONFIG1) kubectl apply -f cluster-1/step-1.cilium.1.14.yaml
cilium-cluster-1-step-2:
	KUBECONFIG=$(KUBECONFIG1) kubectl apply -f cluster-1/step-2.cilium.1.14.yaml

cilium-cluster-1-step-2-config-info:
	@echo '>>>  please execute AFTER cluster 2 setup  <<<'
	@echo
	@echo -- Cluster 1 -------- CILIUM CA -------------------------
	KUBECONFIG=$(KUBECONFIG1) kubectl get secret cilium-ca -n kube-system -o yaml
	@echo -- Cluster 2 -------- CILIUM API server remote cert ----
	KUBECONFIG=$(KUBECONFIG2) kubectl get secret clustermesh-apiserver-remote-cert -n kube-system -o yaml
	@echo -- Cluster 2 -------- CILIUM clustermesh server ---------
	KUBECONFIG=$(KUBECONFIG2) kubectl get svc clustermesh-apiserver -n kube-system
	@echo ---------------------------------------------------------
	@echo '>>>> COPY VALUES to: cluster-1/step-2.cilium.1.14.yaml'
	@echo

cilium-cluster-1-health:
	@echo '>>>  CLUSTER 1  <<<'
	KUBECONFIG=$(KUBECONFIG1) kubectl exec -it -n kube-system ds/cilium -- cilium-health status

## Cluster 2

cilium-cluster-2-default:
	KUBECONFIG=$(KUBECONFIG2) kubectl apply -f cluster-2/default.cilium.1.14.yaml
cilium-cluster-2-step-1:
	KUBECONFIG=$(KUBECONFIG2) kubectl apply -f cluster-2/step-1.cilium.1.14.yaml

cilium-cluster-2-config-info:
	@echo '>>>  please execute AFTER cluster 1 setup STEP 1  <<<'
	@echo
	@echo -- Cluster 1 -------- CILIUM CA -------------------------
	KUBECONFIG=$(KUBECONFIG1) kubectl get secret cilium-ca -n kube-system -o yaml
	@echo -- Cluster 1 -------- CILIUM API server remote cert ----
	KUBECONFIG=$(KUBECONFIG1) kubectl get secret clustermesh-apiserver-remote-cert -n kube-system -o yaml
	@echo -- Cluster 1 -------- CILIUM clustermesh server ---------
	KUBECONFIG=$(KUBECONFIG1) kubectl get svc clustermesh-apiserver -n kube-system
	@echo ---------------------------------------------------------
	@echo '>>>> COPY VALUES to: cluster-2/step-1.cilium.1.14.yaml'
	@echo 

cilium-cluster-2-health:
	@echo '>>>  CLUSTER 2  <<<'
	KUBECONFIG=$(KUBECONFIG2) kubectl exec -it -n kube-system ds/cilium -- cilium-health status


############## SETUP APP
setup-echo:
	KUBECONFIG=$(KUBECONFIG1) kubectl apply -f deployments/cluster1.yaml
	KUBECONFIG=$(KUBECONFIG2) kubectl apply -f deployments/cluster2.yaml
	KUBECONFIG=$(KUBECONFIG3) kubectl apply -f deployments/cluster3.yaml
#endregion Setup

#region Helpers

dig:
	@dig $(DOMAIN) +short

curl-resolved:
	@curl -s -k -H "Host: $(DOMAIN)" -H "Connection: close" https://$(shell dig $(DOMAIN) +short @18.198.114.75 | head -1 ) && echo

repeat:
	@for i in {1..$(TIMES)}; do printf \-;printf " "; $(COMMAND); done

infinity:
	@while true; do printf \-;printf " "; $(COMMAND); done

#region Kubernetes
stop-service:
	KUBECONFIG=$(KUBECONFIG$(CLUSTERID)) kubectl scale deployment echo-service --replicas=0

start-service:
	KUBECONFIG=$(KUBECONFIG$(CLUSTERID)) kubectl scale deployment echo-service --replicas=2

#endregion Kubernetes
#endregion Helpers
helm-download:
	helm repo add cilium https://helm.cilium.io/
	helm repo update
	helm pull --untar -d ./.charts/new cilium/cilium --version 1.16.6
	helm pull --untar -d ./.charts/old cilium/cilium --version 1.14.9


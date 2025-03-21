KUBECONFIG1 := .secrets/cluster1-kubeconfig
KUBECONFIG2 := .secrets/cluster2-kubeconfig

#region Cluster Mesh

clustermesh-deployments:
	@echo "Deploying demo service to all clusters..."
	KUBECONFIG=$(KUBECONFIG1) kubectl apply -f clustermesh/deployments/cluster1.yaml
	# KUBECONFIG=$(KUBECONFIG2) kubectl apply -f clustermesh/deployments/cluster2.yaml
	@echo "Waiting for all pods to be ready..."
	KUBECONFIG=$(KUBECONFIG1) kubectl wait --for=condition=available --timeout=600s deployment/meshed-service
	# KUBECONFIG=$(KUBECONFIG2) kubectl wait --for=condition=available --timeout=600s deployment/meshed-service
	@echo "All pods are ready!"
	@echo "Deploying clustermesh service to all clusters..."
	KUBECONFIG=$(KUBECONFIG1) kubectl apply -f clustermesh/services/cluster1.yaml
	# KUBECONFIG=$(KUBECONFIG2) kubectl apply -f clustermesh/services/cluster1.yaml
	@echo "meshed service deployed to all clusters."

clustermesh-local:
	@echo "Setting up clustermesh for local service affinity..."
	KUBECONFIG=$(KUBECONFIG1) kubectl annotate service meshed-service --overwrite=true io.cilium/service-affinity="local"
	# KUBECONFIG=$(KUBECONFIG2) kubectl annotate service meshed-service --overwrite=true io.cilium/service-affinity="local"

clustermesh-remote:
	@echo "Setting up clustermesh for remote service affinity..."
	KUBECONFIG=$(KUBECONFIG1) kubectl annotate service meshed-service --overwrite=true io.cilium/service-affinity="remote"
	# KUBECONFIG=$(KUBECONFIG2) kubectl annotate service meshed-service --overwrite=true io.cilium/service-affinity="remote"

#endregion Cluster Mesh

#region k8gb

k8gb-setup:
	@echo "Setting up nginx..."
	KUBECONFIG=$(KUBECONFIG1) kubectl create namespace k8gb --dry-run=client -o yaml | KUBECONFIG=$(KUBECONFIG1) kubectl apply -f -
	KUBECONFIG=$(KUBECONFIG1) kubectl create namespace nginx --dry-run=client -o yaml | KUBECONFIG=$(KUBECONFIG1) kubectl apply -f -
	KUBECONFIG=$(KUBECONFIG1) kubectl apply -f k8gb/ingress/cluster1.yaml
	@echo "Setting up k8gb..."
	KUBECONFIG=$(KUBECONFIG1) kubectl create namespace k8gb --dry-run=client -o yaml | KUBECONFIG=$(KUBECONFIG1) kubectl apply -f -
	KUBECONFIG=$(KUBECONFIG1) kubectl apply -f .secrets/cloudflaretoken.yaml
	helm repo add k8gb https://www.k8gb.io
	KUBECONFIG=$(KUBECONFIG1) helm upgrade --install k8gb k8gb/k8gb --namespace k8gb -f k8gb/values/cluster1.yaml
	@echo "k8gb setup complete."

k8gb-deployments:
	@echo "Deploying k8gb deployments..."
	KUBECONFIG=$(KUBECONFIG1) kubectl apply -f k8gb/deployments/cluster1.yaml
	@echo "Waiting for all pods to be ready..."
	KUBECONFIG=$(KUBECONFIG1) kubectl wait --for=condition=available --timeout=600s deployment/meshed-service
	@echo "All pods are ready!"
	KUBECONFIG=$(KUBECONFIG1) kubectl apply -f k8gb/ingress/cluster1.yaml
	@echo "k8gb deployments complete."

#endregion k8gb
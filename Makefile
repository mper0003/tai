SHELL = /usr/bin/env bash -o pipefail

argocd_version := 2.4.12
kubevela_version := 1.6.1
kubevela_version_crds := 1.6

# type of local cluster you would like to run, i.e. kind, k3d, minikube
CLUSTER_TYPE ?=k3d

# list of components you would like to add to your cluster, i.e. argocd, istio, prometheus, etc.
COMPONENTS ?=

# Prints available clusters.
define CLUSTERS
+------------------------------+----------------------------------------------------------------------------------+
| Available targets            | Description                                                                      |
|------------------------------+----------------------------------------------------------------------------------|
| k3d-argocd-cluster-up        | Creates a k3d local cluster with ArgoCD installed.                               |
| k3d-argocd-cluster-down      | Deletes the target/ and .terraform/ directories.                                 |
| argocd-server                | Provides access to the ArgoCD UI.                                                |
|------------------------------+----------------------------------------------------------------------------------|
| upgrade-components           | Downloads the manifests for the component's specified version.                   |
+------------------------------+----------------------------------------------------------------------------------+
endef
export CLUSTERS

.PHONY: help
help:
	@echo "$${CLUSTERS}"

PHONY: create-cluster
create-cluster:
		@echo "\n♻️  Creating Kubernetes cluster 'k3d-local'..."
		 k3d cluster create --config clusters/k3d.yaml

PHONY: delete-cluster
delete-cluster:
		@echo "\n♻️  Deleting Kubernetes cluster 'k3d-local'..."
		 k3d cluster delete --config clusters/k3d.yaml

PHONY: install-argocd
install-argocd: upgrade-components
		@echo "\n♻️  Installing ArgoCD v$(argocd_version)..."
		kustomize build platform/overlays/k3d-argocd/ | kubectl apply -f -

PHONY: uninstall-argocd
uninstall-argocd:
		@echo "\n🛠️ Uninstalling ArgoCD $(argocd_version)..."
		kustomize build platform/overlays/k3d-argocd/ | kubectl delete -f -

PHONY: upgrade-components
upgrade-components:
		@echo "\n♻️  Downloading ArgoCD to version v$(argocd_version)..."
		 curl -sL https://raw.githubusercontent.com/argoproj/argo-cd/v${argocd_version}/manifests/install.yaml > platform/base/argocd/install.yaml

PHONY: argocd-server
argocd-server:
		@echo "\n🔑 Login using user 'admin' and password:\n"
		kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
		@echo "ctl+C to stop forwarding\n"
		kubectl port-forward svc/argocd-server -n argocd 8080:443

PHONY: k3d-argocd-cluster-up
k3d-argocd-cluster-up: create-cluster install-argocd
		@echo "\n🎉️ Successfully setup Kubernetes cluster 'k3d-local' with ArgoCD!"

PHONY: k3d-argocd-cluster-down
k3d-argocd-cluster-down: uninstall-argocd delete-cluster
		@echo "\n🎉 Successfully teared down Kubernetes cluster 'k3d-local'!"

PHONY: argocd-github-auth
argocd-github-auth:
		@echo "\n🛠️ Generating and applying ArgoCD GitHub App secret."
		 cat ./target/secret.json | ./scripts/argocd-github-auth.sh  | kubectl apply -f -

PHONY: argocd-github-auth-delete
argocd-github-auth-delete:
		@echo "\n🛠️ Deleting ArgoCD GitHub App secret."
		 cat ./target/secret.json | ./scripts/argocd-github-auth.sh  | kubectl delete -f -

PHONY: vela-crds
vela-crds:
		curl -s https://raw.githubusercontent.com/oam-dev/kubevela/release-${kubevela_version_crds}/charts/vela-core/crds/core.oam.dev_applicationrevisions.yaml > platform/base/kubevela/core.oam.dev_applicationrevisions.yaml
		curl -s https://raw.githubusercontent.com/oam-dev/kubevela/release-${kubevela_version_crds}/charts/vela-core/crds/core.oam.dev_applications.yaml > platform/base/kubevela/core.oam.dev_applications.yaml
		curl -s https://raw.githubusercontent.com/oam-dev/kubevela/release-${kubevela_version_crds}/charts/vela-core/crds/core.oam.dev_resourcetrackers.yaml > platform/base/kubevela/core.oam.dev_resourcetrackers.yaml
		curl -s https://raw.githubusercontent.com/oam-dev/kubevela/release-${kubevela_version_crds}/charts/vela-core/crds/core.oam.dev_componentdefinitions.yaml > platform/base/kubevela/core.oam.dev_componentdefinitions.yaml
		curl -s https://raw.githubusercontent.com/oam-dev/kubevela/release-${kubevela_version_crds}/charts/vela-core/crds/core.oam.dev_definitionrevisions.yaml > platform/base/kubevela/core.oam.dev_definitionrevisions.yaml


#curl -s https://raw.githubusercontent.com/oam-dev/kubevela/release-${kubevela_version_crds}/charts/vela-core/crds/core.oam.dev_envbindings.yaml > platform/base/kubevela/core.oam.dev_envbindings.yaml
		#curl -s https://raw.githubusercontent.com/oam-dev/kubevela/release-${kubevela_version_crds}/charts/vela-core/crds/core.oam.dev_healthscopes.yaml > platform/base/kubevela/core.oam.dev_healthscopes.yaml
		#curl -s https://raw.githubusercontent.com/oam-dev/kubevela/release-${kubevela_version_crds}/charts/vela-core/crds/core.oam.dev_policies.yaml > platform/base/kubevela/core.oam.dev_policies.yaml
		#curl -s https://raw.githubusercontent.com/oam-dev/kubevela/release-${kubevela_version_crds}/charts/vela-core/crds/core.oam.dev_policydefinitions.yaml > platform/base/kubevela/core.oam.dev_policydefinitions.yaml
		#curl -s https://raw.githubusercontent.com/oam-dev/kubevela/release-${kubevela_version_crds}/charts/vela-core/crds/core.oam.dev_scopedefinitions.yaml > platform/base/kubevela/core.oam.dev_scopedefinitions.yaml
		#curl -s https://raw.githubusercontent.com/oam-dev/kubevela/release-${kubevela_version_crds}/charts/vela-core/crds/core.oam.dev_traitdefinitions.yaml > platform/base/kubevela/core.oam.dev_traitdefinitions.yaml
		#curl -s https://raw.githubusercontent.com/oam-dev/kubevela/release-${kubevela_version_crds}/charts/vela-core/crds/core.oam.dev_workflows.yaml > platform/base/kubevela/core.oam.dev_workflows.yaml
		#curl -s https://raw.githubusercontent.com/oam-dev/kubevela/release-${kubevela_version_crds}/charts/vela-core/crds/core.oam.dev_workflowstepdefinitions.yaml > platform/base/kubevela/core.oam.dev_workflowstepdefinitions.yaml
		#curl -s https://raw.githubusercontent.com/oam-dev/kubevela/release-${kubevela_version_crds}/charts/vela-core/crds/core.oam.dev_workloaddefinitions.yaml > platform/base/kubevela/core.oam.dev_workloaddefinitions.yaml
		#curl -s https://raw.githubusercontent.com/oam-dev/kubevela/release-${kubevela_version_crds}/charts/vela-core/crds/standard.oam.dev_rollouts.yaml  > platform/base/kubevela/standard.oam.dev_rollouts.yaml

PHONY: upgrade-kubevela
upgrade-kubevela: vela-crds
	@echo "\n🛠️ Updating chart for KubeVela $(kubevela_version)."
	@helm repo add kubevela https://charts.kubevela.net/core
	@helm repo update


#	@echo "\n🛠️ Updating chart for KubeVela $(kubevela_version)."
#	@helm upgrade -n vela-system --install kubevela kubevela/vela-core --version ${kubevela_version} --wait

PHONY: install-kubevela
install-kubevela: upgrade-kubevela
	@echo "\n🛠️ Installing KubeVela $(kubevela_version)..."
	kubectl apply -f platform/base/kubevela/namespace.yaml
	helm upgrade -n vela-system --install kubevela kubevela/vela-core --version ${kubevela_version} --wait


	#kustomize build platform/overlays/k3d-vela/ | kubectl apply -f -

PHONY: uninstall-kubevela
uninstall-kubevela:
		@echo "\n🛠️ Uninstalling KubeVela $(kubevela_version)..."
		kustomize build platform/overlays/k3d-vela/ | kubectl delete -f -

PHONY: k3d-vela-up
k3d-vela-up: create-cluster install-kubevela
	@echo "\n🎉️ Successfully setup Kubernetes cluster 'k3d-local' with KubeVela!"

PHONY: k3d-vela-down
k3d-vela-down: uninstall-kubevela delete-cluster
		@echo "\n🎉 Successfully teared down Kubernetes cluster 'k3d-local' with KubeVela!"

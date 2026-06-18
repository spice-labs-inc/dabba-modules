# Local minikube cluster via the scott-the-programmer/minikube provider. Like the
# other substrate modules, its only contract is to produce a kubeconfig — the
# configure layer and gitops run on it unchanged.

resource "minikube_cluster" "this" {
  cluster_name = var.name
  driver       = var.driver
}

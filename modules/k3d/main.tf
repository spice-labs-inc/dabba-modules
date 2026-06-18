# Local k3d (k3s in Docker) cluster, driven via the k3d CLI (there is no solid
# native provider). Like the kind module, its only contract is to produce a
# kubeconfig — everything above the kubeconfig is substrate-agnostic.
#
# Traefik is disabled (the platform installs Envoy Gateway). The host port is
# mapped to the gateway NodePort (30443) so *.localtest.me works, matching kind.

resource "null_resource" "cluster" {
  triggers = {
    name = var.name
  }

  provisioner "local-exec" {
    command = "k3d cluster create ${var.name} --wait --timeout 300s --k3s-arg '--disable=traefik@server:*' -p '${var.host_port}:30443@server:0'"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "k3d cluster delete ${self.triggers.name}"
  }
}

# Read the kubeconfig after the cluster exists (depends_on defers this to apply).
# jq -Rs wraps the raw kubeconfig YAML as the JSON external data sources require.
data "external" "kubeconfig" {
  depends_on = [null_resource.cluster]
  program    = ["bash", "-c", "k3d kubeconfig get ${var.name} | jq -Rs '{content: .}'"]
}

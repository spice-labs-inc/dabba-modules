# Assemble a portable kubeconfig from the provider's connection outputs (PEM),
# so this module's interface matches the kind/k3d modules (a `kubeconfig` string).
output "kubeconfig" {
  description = "Kubeconfig for accessing the cluster"
  sensitive   = true
  value = yamlencode({
    apiVersion        = "v1"
    kind              = "Config"
    "current-context" = var.name
    clusters = [{
      name = var.name
      cluster = {
        server                       = minikube_cluster.this.host
        "certificate-authority-data" = base64encode(minikube_cluster.this.cluster_ca_certificate)
      }
    }]
    users = [{
      name = var.name
      user = {
        "client-certificate-data" = base64encode(minikube_cluster.this.client_certificate)
        "client-key-data"         = base64encode(minikube_cluster.this.client_key)
      }
    }]
    contexts = [{
      name    = var.name
      context = { cluster = var.name, user = var.name }
    }]
  })
}

output "name" {
  value = var.name
}

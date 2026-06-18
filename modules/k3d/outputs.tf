output "kubeconfig" {
  description = "Kubeconfig for accessing the cluster"
  value       = data.external.kubeconfig.result.content
  sensitive   = true
}

output "name" {
  value = var.name
}

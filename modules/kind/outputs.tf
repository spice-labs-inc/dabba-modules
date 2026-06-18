output "kubeconfig" {
  description = "Kubeconfig for accessing the cluster"
  value       = kind_cluster.this.kubeconfig
  sensitive   = true
}

output "name" {
  value = kind_cluster.this.name
}

output "cluster_ca_certificate" {
  value = kind_cluster.this.cluster_ca_certificate
}

output "client_certificate" {
  value = kind_cluster.this.client_certificate
}

output "client_key" {
  value     = kind_cluster.this.client_key
  sensitive = true
}

output "cluster_endpoint" {
  value = kind_cluster.this.endpoint
}

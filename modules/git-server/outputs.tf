output "namespace" {
  value = kubernetes_namespace_v1.git_server.metadata[0].name
}

output "gitops_repo_url" {
  description = "In-cluster URL for a gitops repo owned by the admin user (point the FluxInstance sync here)"
  value       = "http://${local.service_host}:3000/${var.admin_username}/dabba-gitops.git"
}

output "service_host" {
  value = local.service_host
}

output "admin_username" {
  value = var.admin_username
}

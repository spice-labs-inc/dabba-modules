# The substrate seam. Kapsule hands back a complete kubeconfig, so unlike the
# eks module there is nothing to assemble here.
#
# Worth knowing about its shape: this kubeconfig embeds a bearer token rather
# than an exec block that fetches one. That makes it usable with no CLI on PATH,
# and it also makes the file itself a credential — anyone holding it holds
# cluster access until the token is revoked, with no second factor. dabba writes
# it 0600 into the environment's working directory; treat it the way you would
# treat a private key, not the way you would treat an AWS kubeconfig.
output "kubeconfig" {
  description = "Kubeconfig for reaching the cluster — the substrate seam"
  value       = scaleway_k8s_cluster.this.kubeconfig[0].config_file
  sensitive   = true
}

output "name" {
  value = scaleway_k8s_cluster.this.name
}

output "region" {
  value = var.region
}

output "zone" {
  value = var.zone
}

output "cluster_id" {
  value = scaleway_k8s_cluster.this.id
}

output "cluster_endpoint" {
  value = scaleway_k8s_cluster.this.apiserver_url
}

# Surfaced so gitops content can attach to the same network as the cluster —
# the Scaleway analogue of the vpc/subnet outputs the eks module exposes.
output "private_network_id" {
  value = local.private_network_id
}

output "wildcard_dns" {
  description = "Kapsule's per-cluster wildcard DNS name. Useful for reaching Ingress/Gateway endpoints before a real domain is delegated, the way nip.io is used locally."
  value       = scaleway_k8s_cluster.this.wildcard_dns
}

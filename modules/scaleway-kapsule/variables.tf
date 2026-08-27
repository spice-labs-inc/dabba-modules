variable "name" {
  description = "Cluster name (also the base for the private network and node pool names)"
  type        = string
  default     = "dabba"
}

variable "region" {
  description = "Scaleway region for the cluster control plane (fr-par, nl-ams, pl-waw)"
  type        = string
  default     = "fr-par"
}

variable "zone" {
  description = "Scaleway zone for the node pool. Must be inside var.region — a pool in a zone belonging to another region is rejected at apply, not at plan."
  type        = string
  default     = "fr-par-1"
}

variable "k8s_version" {
  description = "Kapsule Kubernetes version. dabba needs >= 1.31 (external-secrets CRDs use selectableFields), matching the floor the eks module documents."
  type        = string
  default     = "1.31"
}

variable "node_type" {
  description = "Instance type for pool nodes. The default is the smallest that comfortably fits dabba's platform set (Flux, Forgejo, cert-manager, Envoy Gateway, OpenBao) with room for workloads; smaller types will schedule but evict under load."
  type        = string
  default     = "PRO2-XXS"
}

variable "node_count" {
  description = "Nodes in the pool when autoscaling is off, and the starting size when it is on."
  type        = number
  default     = 2
}

variable "autoscaling" {
  description = "Let Kapsule scale the pool between min_node_count and max_node_count."
  type        = bool
  default     = false
}

variable "min_node_count" {
  description = "Lower bound when autoscaling is enabled."
  type        = number
  default     = 2
}

variable "max_node_count" {
  description = "Upper bound when autoscaling is enabled. Also the ceiling on what this cluster can cost, which is the reason it has a conservative default rather than none."
  type        = number
  default     = 4
}

variable "private_network_id" {
  description = "Use an existing VPC private network instead of creating one. Kapsule requires a private network, so leaving this empty provisions a dedicated one. Set it to place the cluster alongside existing Scaleway resources."
  type        = string
  default     = ""
}

variable "cni" {
  description = "Container network interface. Cilium is Scaleway's default and the only one dabba has been exercised against."
  type        = string
  default     = "cilium"
}

variable "delete_additional_resources" {
  description = "On destroy, also remove the load balancers and block volumes Kubernetes created. Default true so `dabba down` leaves nothing billable behind — the opposite of the compose backend's never-destroy contract, because here the cluster itself is the thing being torn down and orphaned cloud resources cost money silently."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to the cluster and pool."
  type        = list(string)
  default     = ["dabba"]
}

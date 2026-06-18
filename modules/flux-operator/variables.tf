variable "gitops_repo_url" {
  type        = string
  description = "HTTPS URL of the gitops repository the FluxInstance reconciles from"
}

variable "gitops_ref" {
  type        = string
  description = "Git reference for the sync, e.g. refs/heads/main or refs/tags/v1.0.0"
  default     = "refs/heads/main"
}

variable "sync_path" {
  type        = string
  description = "Path in the gitops repo the root sync Kustomization applies (holds the per-cluster Kustomizations)"
  default     = "clusters/local"
}

variable "cluster_vars" {
  type        = map(string)
  description = "Values stamped into the cluster-vars ConfigMap and consumed by Kustomizations via postBuild.substituteFrom (e.g. domain, cluster_issuer). This is the cluster's self-describing config."
  default     = {}
}

variable "namespace" {
  type        = string
  description = "Namespace for the flux operator, instance, and cluster-vars ConfigMap"
  default     = "flux-system"
}

variable "flux_version" {
  type        = string
  description = "Flux distribution version range the operator installs"
  default     = "2.x"
}

variable "operator_chart_version" {
  type        = string
  description = "flux-operator chart version (null = latest; pin for releases)"
  nullable    = true
  default     = null
}

variable "instance_chart_version" {
  type        = string
  description = "flux-instance chart version (null = latest; pin for releases)"
  nullable    = true
  default     = null
}

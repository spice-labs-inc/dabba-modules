variable "namespace" {
  type        = string
  description = "Namespace for the in-cluster git server"
  default     = "git-server"
}

variable "admin_username" {
  type        = string
  description = "Forgejo admin username (also the owner of the gitops repo)"
  default     = "dabba"
}

variable "admin_password" {
  type        = string
  description = "Forgejo admin password — REQUIRED (no shipped default). The dabba CLI generates a per-env random one and stores it in OpenBao."
  sensitive   = true
}

variable "admin_email" {
  type        = string
  description = "Forgejo admin email"
  default     = "admin@dabba.local"
}

variable "persistence" {
  type        = bool
  description = "Persist Forgejo data on a PVC. Off makes the server ephemeral (fine for local/test); on for longer-lived use, where Forgejo holds your gitops history."
  default     = true
}

variable "chart_version" {
  type        = string
  description = "Forgejo chart version (null = latest; pin for releases)"
  nullable    = true
  default     = null
}

variable "image_registry" {
  type        = string
  description = "Registry for the Forgejo image. Defaults to the dabba ghcr mirror (fast). null uses the chart upstream default (code.forgejo.org)."
  nullable    = true
  default     = "ghcr.io"
}

variable "image_repository" {
  type        = string
  description = "Repository path for the Forgejo image. null uses the chart upstream default (forgejo/forgejo)."
  nullable    = true
  default     = "spice-labs-inc/forgejo"
}

variable "image_tag" {
  type        = string
  description = "Forgejo image tag in appVersion form (the chart appends -rootless), e.g. 15.0.3. null uses the chart default (chart appVersion)."
  nullable    = true
  default     = "15.0.3"
}

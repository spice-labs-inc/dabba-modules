variable "name" {
  description = "Cluster name"
  type        = string
  default     = "dabba"
}

variable "k8s_version" {
  description = "Kubernetes version (kindest/node image tag)"
  type        = string
  default     = "v1.32.2"
}

variable "port_mappings" {
  description = "NodePorts on the control-plane node exposed as host ports, so an in-cluster gateway NodePort service is reachable on localhost. Host ports default to the uncommon 31080/31443 (not 80/443) so dabba does not fight whatever already holds the privileged ports on a dev box."
  type = list(object({
    container_port = number
    host_port      = number
  }))
  default = [
    { container_port = 30080, host_port = 31080 },
    { container_port = 30443, host_port = 31443 },
  ]
}

variable "worker_count" {
  description = "Number of worker nodes in addition to the control plane"
  type        = number
  default     = 0
}

variable "registry_mirrors" {
  description = "Map of registry host to mirror endpoint, e.g. { \"docker.io\" = \"http://cache:5000\" }. Empty for none; used to point kind at a local pull-through cache."
  type        = map(string)
  default     = {}
}

variable "name" {
  description = "Cluster name"
  type        = string
  default     = "dabba"
}

variable "driver" {
  description = "minikube driver"
  type        = string
  default     = "docker"
}

variable "registry_mirrors" {
  description = "Accepted for interface parity with the kind module. Not yet wired into minikube."
  type        = map(string)
  default     = {}
}

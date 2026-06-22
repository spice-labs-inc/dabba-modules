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

# Declared for interface parity: 01-cluster passes registry_mirrors to whichever
# substrate module is selected; minikube accepts it but doesn't wire it yet.
# tflint-ignore: terraform_unused_declarations
variable "registry_mirrors" {
  description = "Accepted for interface parity with the kind module. Not yet wired into minikube."
  type        = map(string)
  default     = {}
}

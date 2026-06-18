variable "name" {
  description = "Cluster name"
  type        = string
  default     = "dabba"
}

variable "host_port" {
  description = "Host port mapped to the gateway NodePort (30443), so an in-cluster gateway is reachable at localhost / *.localtest.me. Defaults to the uncommon 31443 (not 443) so dabba does not fight whatever already holds the privileged ports on a dev box."
  type        = number
  default     = 31443
}

variable "registry_mirrors" {
  description = "Accepted for interface parity with the kind module. Not yet wired into k3d's registry config."
  type        = map(string)
  default     = {}
}

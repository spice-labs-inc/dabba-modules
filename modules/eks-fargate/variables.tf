variable "name" {
  description = "Cluster name (also the base for VPC, EFS, and role names)"
  type        = string
  default     = "dabba"
}

variable "region" {
  description = "AWS region to create the cluster in"
  type        = string
  default     = "us-east-1"
}

variable "k8s_version" {
  description = "EKS Kubernetes version. dabba needs >= 1.31 (external-secrets CRDs use selectableFields)."
  type        = string
  default     = "1.31"
}

variable "vpc_id" {
  description = "Use an existing VPC instead of creating one. Empty (default) provisions a dedicated VPC. When set, private_subnet_ids and public_subnet_ids must be provided, and the subnets must carry the EKS load-balancer role tags (kubernetes.io/role/internal-elb and .../elb)."
  type        = string
  default     = ""
}

variable "private_subnet_ids" {
  description = "Private subnet ids to run the cluster/Fargate/EFS in. Required when vpc_id is set; ignored when provisioning a VPC."
  type        = list(string)
  default     = []
}

variable "public_subnet_ids" {
  description = "Public subnet ids for the internet-facing load balancer. Required when vpc_id is set; ignored when provisioning a VPC."
  type        = list(string)
  default     = []
}

variable "vpc_cidr" {
  description = "CIDR for the provisioned VPC (only used when vpc_id is empty)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of availability zones to spread provisioned subnets across (2 is the EKS minimum; only used when vpc_id is empty)"
  type        = number
  default     = 2
}

variable "fargate_namespaces" {
  description = "Namespaces that get a Fargate profile selector. Every pod dabba runs must be covered, including kube-system so CoreDNS schedules. The platform namespaces are the dabba component set."
  type        = list(string)
  default = [
    "kube-system",
    "flux-system",
    "dabba-system",
    "git-server",
    "cert-manager",
    "external-secrets",
    "external-dns",
    "cluster-secrets",
    "envoy-gateway",
    "openbao",
    "podinfo",
    "observability",
  ]
}

variable "route53_zone_id" {
  description = "Route53 hosted zone id for the dabba subdomain (e.g. eks.spice-labs.dev). Scopes the external-dns and cert-manager IRSA roles to just this zone. Empty = grant no Route53 access yet (DNS/ACME stay dormant until a zone is delegated)."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags applied to every taggable resource"
  type        = map(string)
  default = {
    "app.kubernetes.io/part-of" = "dabba"
  }
}

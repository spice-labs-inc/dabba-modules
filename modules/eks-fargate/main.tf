data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  # Provision a dedicated VPC unless the caller brought their own.
  create_vpc         = var.vpc_id == ""
  vpc_id             = local.create_vpc ? module.vpc[0].vpc_id : var.vpc_id
  private_subnet_ids = local.create_vpc ? module.vpc[0].private_subnets : var.private_subnet_ids

  # Scope the external-dns / cert-manager roles to the delegated zone, or to none
  # until one is provided (DNS + ACME stay dormant rather than over-permissioned).
  route53_zone_arns = var.route53_zone_id == "" ? [] : ["arn:aws:route53:::hostedzone/${var.route53_zone_id}"]
  route53_enabled   = var.route53_zone_id != ""
}

# A bring-your-own VPC needs both subnet lists, and the subnets must be EKS-tagged.
check "byo_vpc_needs_subnets" {
  assert {
    condition     = local.create_vpc || (length(var.private_subnet_ids) > 0 && length(var.public_subnet_ids) > 0)
    error_message = "When vpc_id is set, private_subnet_ids and public_subnet_ids must both be provided."
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.8"
  count   = local.create_vpc ? 1 : 0

  name = "${var.name}-vpc"
  cidr = var.vpc_cidr
  azs  = local.azs

  private_subnets = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 4, i)]
  public_subnets  = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 4, i + 8)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # Subnet tags the AWS Load Balancer Controller uses to auto-discover where to
  # place internet-facing (public) vs internal (private) load balancers.
  public_subnet_tags  = { "kubernetes.io/role/elb" = "1" }
  private_subnet_tags = { "kubernetes.io/role/internal-elb" = "1" }

  tags = var.tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.24"

  cluster_name    = var.name
  cluster_version = var.k8s_version

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  vpc_id     = local.vpc_id
  subnet_ids = local.private_subnet_ids

  # CoreDNS defaults to EC2 compute; the override lets it schedule on Fargate
  # with no EC2 nodes present (without it, DNS never comes up on a pure-Fargate cluster).
  cluster_addons = {
    coredns = {
      configuration_values = jsonencode({ computeType = "Fargate" })
    }
  }

  # Fargate profiles covering every namespace dabba runs pods in (kube-system
  # included so CoreDNS and add-on controllers schedule). EKS caps a profile at 5
  # selectors, so the namespaces are chunked across as many profiles as needed.
  fargate_profiles = {
    for i, chunk in chunklist(var.fargate_namespaces, 5) : "dabba-${i}" => {
      name       = "dabba-${i}"
      selectors  = [for ns in chunk : { namespace = ns }]
      subnet_ids = local.private_subnet_ids
    }
  }

  tags = var.tags
}

# IRSA roles for the cloud controllers. The roles are created by tofu (IAM is
# cloud infra); the controllers install from gitops and assume these via their
# service account. The ARNs are surfaced as outputs -> cluster-vars ConfigMap.

module "irsa_lb_controller" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.44"

  role_name                              = "${var.name}-aws-lb-controller"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
  tags = var.tags
}

module "irsa_external_dns" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.44"

  role_name                     = "${var.name}-external-dns"
  attach_external_dns_policy    = local.route53_enabled
  external_dns_hosted_zone_arns = local.route53_zone_arns

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["external-dns:external-dns"]
    }
  }
  tags = var.tags
}

module "irsa_cert_manager" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.44"

  role_name                     = "${var.name}-cert-manager"
  attach_cert_manager_policy    = local.route53_enabled
  cert_manager_hosted_zone_arns = local.route53_zone_arns

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["cert-manager:cert-manager"]
    }
  }
  tags = var.tags
}

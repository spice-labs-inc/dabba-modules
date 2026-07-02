locals {
  # Exec-auth kubeconfig: the token is minted on demand by the aws CLI, so this
  # stays valid without embedding a short-lived credential. Requires `aws` on PATH.
  kubeconfig = yamlencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = var.name
    clusters = [{
      name = var.name
      cluster = {
        server                     = module.eks.cluster_endpoint
        certificate-authority-data = module.eks.cluster_certificate_authority_data
      }
    }]
    contexts = [{
      name = var.name
      context = {
        cluster = var.name
        user    = var.name
      }
    }]
    users = [{
      name = var.name
      user = {
        exec = {
          apiVersion = "client.authentication.k8s.io/v1beta1"
          command    = "aws"
          args       = ["--region", var.region, "eks", "get-token", "--cluster-name", var.name]
        }
      }
    }]
  })
}

output "kubeconfig" {
  description = "Kubeconfig (exec auth via the aws CLI) for reaching the cluster — the substrate seam"
  value       = local.kubeconfig
  sensitive   = true
}

output "name" {
  value = module.eks.cluster_name
}

output "region" {
  value = var.region
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

# Surfaced into the cluster-vars ConfigMap so gitops controllers can annotate
# their service accounts with the role to assume (IRSA).
output "lb_controller_role_arn" {
  value = module.irsa_lb_controller.iam_role_arn
}

output "external_dns_role_arn" {
  value = module.irsa_external_dns.iam_role_arn
}

output "cert_manager_role_arn" {
  value = module.irsa_cert_manager.iam_role_arn
}

output "vpc_id" {
  value = local.vpc_id
}

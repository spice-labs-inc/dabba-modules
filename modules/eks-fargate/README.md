# eks-fargate

Provisions an [AWS EKS](https://aws.amazon.com/eks/) cluster running entirely on
[Fargate](https://docs.aws.amazon.com/eks/latest/userguide/fargate.html) (no EC2 nodes).
This is dabba's first cloud substrate: its contract is the same as any local cluster
module — produce a kubeconfig for the configuration layer to consume.

It creates a VPC, the EKS control plane, a Fargate profile covering every namespace dabba
runs (CoreDNS is scheduled on Fargate too), an OIDC provider, and IRSA roles for the cloud
controllers (AWS Load Balancer Controller, external-dns, cert-manager).

The kubeconfig uses exec auth (`aws eks get-token`), so it needs the `aws` CLI on PATH.

DNS + TLS are dormant until a Route53 zone is supplied: set `route53_zone_id` to scope the
external-dns and cert-manager roles to a single delegated zone (e.g. `eks.spice-labs.dev`).
Left empty, those roles are created with no Route53 access and the DNS/ACME gitops components
stay off.

By default it provisions a dedicated VPC (2 public + 2 private subnets, IGW, one NAT
gateway). To reuse an existing VPC, set `vpc_id` plus `private_subnet_ids` and
`public_subnet_ids` — the subnets must carry the EKS load-balancer role tags
(`kubernetes.io/role/internal-elb` on private, `kubernetes.io/role/elb` on public).

## Usage

```hcl
module "cluster" {
  source = "git::https://github.com/spice-labs-inc/dabba-modules.git//modules/eks-fargate?ref=main"

  name            = "dabba"
  region          = "us-east-1"
  route53_zone_id = "" # set once eks.spice-labs.dev is delegated to Route53

  # Optional: reuse an existing VPC instead of provisioning one.
  # vpc_id             = "vpc-0abc123"
  # private_subnet_ids = ["subnet-0aaa", "subnet-0bbb"]
  # public_subnet_ids  = ["subnet-0ccc", "subnet-0ddd"]
}
```

## Variables

| Name | Description | Default |
|------|-------------|---------|
| `name` | Cluster name (base for VPC/EFS/role names) | `dabba` |
| `region` | AWS region | `us-east-1` |
| `k8s_version` | EKS Kubernetes version (dabba needs >= 1.31) | `1.31` |
| `vpc_id` | Reuse an existing VPC (empty = provision one) | `""` |
| `private_subnet_ids` | Private subnets (required when `vpc_id` is set) | `[]` |
| `public_subnet_ids` | Public subnets (required when `vpc_id` is set) | `[]` |
| `vpc_cidr` | CIDR for the provisioned VPC (when `vpc_id` empty) | `10.0.0.0/16` |
| `az_count` | AZs to spread provisioned subnets across | `2` |
| `fargate_namespaces` | Namespaces given a Fargate profile selector | dabba platform set + `kube-system` |
| `route53_zone_id` | Hosted zone id to scope external-dns/cert-manager to (empty = DNS/ACME off) | `""` |
| `tags` | Tags applied to every resource | `{ app.kubernetes.io/part-of = dabba }` |

## Outputs

`kubeconfig` (sensitive), `name`, `region`, `cluster_endpoint`, `oidc_provider_arn`,
`lb_controller_role_arn`, `external_dns_role_arn`, `cert_manager_role_arn`, `vpc_id`.

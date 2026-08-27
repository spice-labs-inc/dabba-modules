# scaleway-kapsule

Provisions a [Scaleway Kapsule](https://www.scaleway.com/en/kubernetes-kapsule/)
cluster. Its contract is the same as any other substrate module — produce a
kubeconfig for the configuration layer to consume — so everything above that seam
(Flux, Forgejo, cert-manager, Envoy Gateway, the gitops content) is byte-identical
to what runs on kind.

It creates a VPC private network (Kapsule requires one), the managed control
plane, and a single node pool with autohealing on.

## How it differs from eks-fargate

**The kubeconfig is complete and self-contained.** Kapsule returns one with a
bearer token in it, so there is no exec-auth block and nothing needs a cloud CLI
on PATH. The trade is that the file *is* a credential rather than a pointer to
one: whoever holds it has cluster access until the token is revoked, with no
second factor. dabba writes it `0600` into the environment's working directory.
Treat it like a private key.

**Nodes are real machines, not Fargate.** EKS-on-Fargate has no nodes to size;
here you pick a `node_type` and a count, and they are what the cluster costs. The
default (`PRO2-XXS` × 2) is the smallest that comfortably fits dabba's platform
set with room for workloads. Smaller types will schedule and then evict under
load, which presents as pods restarting for no visible reason.

**Destroy removes cloud resources Kubernetes created.**
`delete_additional_resources` defaults to `true`, so load balancers and block
volumes go with the cluster. Left `false`, `dabba down` returns cleanly and
leaves billable resources behind with nothing pointing at them.

## Credentials

The provider reads `SCW_ACCESS_KEY`, `SCW_SECRET_KEY` and
`SCW_DEFAULT_PROJECT_ID` from the environment, or `~/.config/scw/config.yaml`.
They are deliberately not module variables: a credential passed as a terraform
variable is written into the state file.

## Upgrades

Patch versions apply themselves in a Sunday 03:00 maintenance window. Minor
upgrades stay deliberate, because a minor bump can move CRD API versions out from
under the gitops content — which is the failure that looks like "Flux stopped
reconciling for no reason".

## Usage

```hcl
module "cluster" {
  source = "git::https://github.com/spice-labs-inc/dabba-modules.git//modules/scaleway-kapsule?ref=main"

  name        = "dabba"
  region      = "fr-par"
  zone        = "fr-par-1"
  k8s_version = "1.31"
  node_type   = "PRO2-XXS"
  node_count  = 2
}
```

Or through dabba, which is the intended path:

```yaml
environments:
  - name: cloud
    substrate: scaleway-kapsule
    substrateConfig:
      region: fr-par
      zone: fr-par-1
      nodeType: PRO2-XXS
      nodeCount: 2
```

| Input | Default | Notes |
| --- | --- | --- |
| `name` | `dabba` | Also names the private network and pool |
| `region` | `fr-par` | Control plane region |
| `zone` | `fr-par-1` | Pool zone; must be inside `region` |
| `k8s_version` | `1.31` | dabba's floor — external-secrets CRDs need it |
| `node_type` | `PRO2-XXS` | See sizing note above |
| `node_count` | `2` | Pool size, or starting size when autoscaling |
| `autoscaling` | `false` | Bounded by `min_node_count`/`max_node_count` |
| `max_node_count` | `4` | Also the ceiling on what this cluster can cost |
| `private_network_id` | `""` | Empty provisions a dedicated network |
| `cni` | `cilium` | Scaleway's default; the only one dabba is exercised against |
| `delete_additional_resources` | `true` | See destroy note above |

| Output | Notes |
| --- | --- |
| `kubeconfig` | The substrate seam (sensitive) |
| `cluster_endpoint` | API server URL |
| `private_network_id` | For gitops content that needs the same network |
| `wildcard_dns` | Per-cluster wildcard, useful before a real domain is delegated |

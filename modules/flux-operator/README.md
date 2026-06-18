# flux-operator

Bootstraps FluxCD on a cluster using the
[Flux Operator](https://github.com/controlplaneio-fluxcd/flux-operator). Installs the
operator and a `FluxInstance` (which installs Flux and starts the gitops sync), and stamps
a `cluster-vars` ConfigMap that the gitops repo's Kustomizations read via
`postBuild.substituteFrom`.

This replaces the older pattern of generating GitRepository/Kustomization objects from
terraform: the structure now lives in the gitops repo (`<sync_path>/`), terraform only
points Flux at it and provides the per-cluster values. The cluster becomes self-describing,
and the gitops repo can also be driven without terraform (`flux-operator` install +
a FluxInstance + the ConfigMap).

Needs only a kubeconfig — pass configured `helm` and `kubernetes` providers.

## Usage

```hcl
module "flux" {
  source = "git::https://github.com/spice-labs-inc/dabba-modules.git//modules/flux-operator?ref=main"

  gitops_repo_url = "https://github.com/spice-labs-inc/dabba-gitops.git"
  gitops_ref      = "refs/heads/main"
  sync_path       = "clusters/local"

  cluster_vars = {
    domain         = "localtest.me"
    cluster_issuer = "dabba-ca"
    cluster        = "dabba"
    environment    = "local"
  }

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }
}
```

## Variables

| Name | Description | Default |
|------|-------------|---------|
| `gitops_repo_url` | HTTPS URL of the gitops repo | required |
| `gitops_ref` | git ref for the sync (`refs/heads/…`, `refs/tags/…`) | `refs/heads/main` |
| `sync_path` | path the root sync Kustomization applies | `clusters/local` |
| `cluster_vars` | values for the `cluster-vars` ConfigMap (substituteFrom) | `{}` |
| `namespace` | flux namespace | `flux-system` |
| `flux_version` | Flux distribution version range | `2.x` |
| `operator_chart_version` / `instance_chart_version` | chart pins | `null` (latest) |

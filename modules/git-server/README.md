# git-server

An in-cluster [Forgejo](https://forgejo.org/) — the authoritative git source the platform
reconciles from. Flux always syncs from this server; the server gets its content either
seeded from a local path (air-gapped / local) or push-mirrored out to an external host like
GitHub for backup and visibility. Because it hosts PRs, review, and Forgejo Actions, the
whole propose → review → merge → reconcile loop can live in the cluster.

Runs as a single pod backed by SQLite. Installed at bootstrap (alongside the Flux Operator),
not via gitops — it can't be reconciled from the content it serves.

Needs only a kubeconfig — pass configured `helm` and `kubernetes` providers.

## Usage

```hcl
module "git_server" {
  source = "git::https://github.com/spice-labs-inc/dabba-modules.git//modules/git-server?ref=v1.0.0"

  persistence = false # ephemeral for local/test; true for longer-lived use

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }
}

# point the FluxInstance at it
module "flux" {
  source          = ".../modules/flux-operator"
  gitops_repo_url = module.git_server.gitops_repo_url
  # ...
}
```

## Variables

| Name | Description | Default |
|------|-------------|---------|
| `namespace` | namespace for Forgejo | `git-server` |
| `admin_username` | admin user / gitops repo owner | `dabba` |
| `admin_password` | admin password — **required**, no default (the dabba CLI generates a per-env random one and stores it in OpenBao) | _(required)_ |
| `persistence` | persist data on a PVC | `true` |
| `chart_version` | Forgejo chart pin | `null` (latest) |
| `image_registry` / `image_repository` / `image_tag` | Forgejo image (defaults to the ghcr mirror) | `ghcr.io` / `spice-labs-inc/forgejo` / `15.0.3` |

## Image source

`code.forgejo.org` is a slow registry, so by default this module pulls Forgejo from
`ghcr.io/spice-labs-inc/forgejo` — a digest-preserving (byte-identical, verifiable) copy of
the official image served fast from ghcr's CDN, kept current by the
[`mirror-forgejo`](../../.github/workflows/mirror-forgejo.yml) workflow. The tag is the
appVersion form; the chart appends `-rootless`.

To pull from upstream instead, set `image_registry = null` (and `image_repository`/`image_tag`
to null). On a Forgejo version bump: re-run `mirror-forgejo` with the new tag, then bump
`image_tag` here.

## Outputs

`gitops_repo_url` (in-cluster URL to feed the FluxInstance), `service_host`, `namespace`,
`admin_username`.

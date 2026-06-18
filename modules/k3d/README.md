# k3d

Provisions a local [k3d](https://k3d.io/) (k3s in Docker) cluster as an alternative local
substrate to [`kind`](../kind). Driven via the k3d CLI (no solid native provider exists).
Its contract is the same as any cluster module — produce a kubeconfig — so the configure
layer (`flux-operator`, `git-server`) and the gitops platform run on it unchanged.

Requires the `k3d` CLI and Docker on the host. Traefik is disabled (the platform installs
Envoy Gateway); the host port is mapped to the gateway NodePort so `*.localtest.me:31443` works.

## Usage

```hcl
module "cluster" {
  source = "git::https://github.com/spice-labs-inc/dabba-modules.git//modules/k3d?ref=v1.0.0"
}
```

## Variables

| Name | Description | Default |
|------|-------------|---------|
| `name` | cluster name | `dabba` |
| `host_port` | host port mapped to the gateway NodePort (30443) | `31443` |
| `registry_mirrors` | accepted for parity with the kind module; not yet wired into k3d | `{}` |

## Outputs

`kubeconfig` (sensitive), `name`.

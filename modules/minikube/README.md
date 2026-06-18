# minikube

Provisions a local [minikube](https://minikube.sigs.k8s.io/) cluster (via the
[scott-the-programmer/minikube](https://registry.terraform.io/providers/scott-the-programmer/minikube)
provider) as an alternative local substrate to [`kind`](../kind) and [`k3d`](../k3d). Its
contract is the same — produce a kubeconfig — so the configure layer (`flux-operator`,
`git-server`) and the gitops platform run on it unchanged.

Requires Docker (the default driver). The kubeconfig is assembled from the provider's
connection outputs so it matches the other substrate modules' interface.

Unlike [`kind`](../kind) and [`k3d`](../k3d), this module does not publish host ports, so
`*.localtest.me` won't reach the gateway over `localhost`. Reach in-cluster services via the
minikube node IP (`minikube ip`) or `minikube tunnel`.

## Usage

```hcl
module "cluster" {
  source = "git::https://github.com/spice-labs-inc/dabba-modules.git//modules/minikube?ref=v1.0.0"
}
```

## Variables

| Name | Description | Default |
|------|-------------|---------|
| `name` | cluster name | `dabba` |
| `driver` | minikube driver | `docker` |
| `registry_mirrors` | accepted for parity with the kind module; not yet wired into minikube | `{}` |

## Outputs

`kubeconfig` (sensitive), `name`.

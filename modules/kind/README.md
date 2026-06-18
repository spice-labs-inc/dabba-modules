# kind

Provisions a local [kind](https://kind.sigs.k8s.io/) (Kubernetes in Docker) cluster.
This is the local substrate for the dabba platform: its contract is the same as any
cloud cluster module — produce a kubeconfig for the configuration layer to consume.

By default the control-plane node maps NodePorts 30080/30443 to host ports 31080/31443
(uncommon high ports, so dabba doesn't fight whatever already holds 80/443 on the host), so a
gateway Service of type NodePort inside the cluster is reachable at `http://localhost:31080` /
`https://localhost:31443` (and therefore at `*.localtest.me:31443`).

## Usage

```hcl
module "cluster" {
  source = "git::https://github.com/spice-labs-inc/dabba-modules.git//modules/kind?ref=v1.0.0"
}
```

## Variables

| Name | Description | Default |
|------|-------------|---------|
| `name` | Cluster name | `dabba` |
| `k8s_version` | kindest/node image tag | `v1.32.2` |
| `port_mappings` | container→host port mappings on the control-plane node | 30080→31080, 30443→31443 |
| `worker_count` | extra worker nodes | `0` |

## Outputs

`kubeconfig` (sensitive), `name`, `cluster_endpoint`, `cluster_ca_certificate`,
`client_certificate`, `client_key` (sensitive).

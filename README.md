# 🧱 dabba-modules

[![GitHub Release](https://img.shields.io/github/v/release/spice-labs-inc/dabba-modules?label=Release)](https://github.com/spice-labs-inc/dabba-modules/releases)
[![CI](https://github.com/spice-labs-inc/dabba-modules/actions/workflows/ci.yml/badge.svg)](https://github.com/spice-labs-inc/dabba-modules/actions/workflows/ci.yml)
[![License: Apache-2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

The OpenTofu modules behind [dabba](https://github.com/spice-labs-inc/dabba). They provision a
Kubernetes cluster and install the platform's bootstrap layer — an in-cluster git server and
the Flux Operator — onto it. The `dabba` CLI drives them; you can also use them directly.

The modules split in two by what they need and produce. A **provision** module creates a
cluster and outputs a kubeconfig; a **configure** module needs nothing but a kubeconfig.
Everything above the kubeconfig is substrate-agnostic, so the same configure modules run on
every cluster — a local one or a cloud one.

## Modules

| Module | Layer | What it does |
|--------|-------|--------------|
| [`kind`](modules/kind) | provision | Local kind cluster with host port mappings for `*.localtest.me` ingress |
| [`k3d`](modules/k3d) | provision | Local k3d (k3s in Docker) cluster — alternative local substrate |
| [`minikube`](modules/minikube) | provision | Local minikube cluster — alternative local substrate |
| [`git-server`](modules/git-server) | configure | In-cluster Forgejo — the git source the platform reconciles from |
| [`flux-operator`](modules/flux-operator) | configure | Installs the Flux Operator + a FluxInstance and stamps the `cluster-vars` ConfigMap |

Cloud provisioning and observability modules are added as the platform tiers grow — see the
[dabba roadmap](https://github.com/spice-labs-inc/dabba).

## Usage

Pin modules by tag:

```hcl
module "cluster" {
  source = "git::https://github.com/spice-labs-inc/dabba-modules.git//modules/kind?ref=v1.0.0"
}
```

The modules work with [OpenTofu](https://opentofu.org/) (the default for dabba) or Terraform.
Releases follow semver; breaking variable changes bump the major version.

## Contributing & license

Issues are welcome. Feature PRs need a prior issue; reviews may be slow — this project is
maintained as part of our own infrastructure and shared in the hope it is useful. See
[CONTRIBUTING.md](CONTRIBUTING.md). Apache-2.0 — see [LICENSE](LICENSE).

---

A [Spice Labs](https://spicelabs.io) project. © 2026 Spice Labs, Inc. &amp; Contributors.

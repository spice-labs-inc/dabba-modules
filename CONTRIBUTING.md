# Contributing to dabba-modules

Thank you for your interest. These modules are maintained as part of our own infrastructure
and shared in the hope they are useful. We welcome bug reports, questions, and documentation
fixes. For features, please open an issue first so we can align before you invest time — and
note that reviews may be slow. The maintainers make the final call on what fits the project.

## Reporting bugs

Open a [new issue](../../issues/new) with a clear title, what you expected vs. what happened,
a minimal reproduction, and your OpenTofu/Terraform and provider versions.

## Working in this repo

These are the OpenTofu/Terraform modules for the [dabba](https://github.com/spice-labs-inc/dabba)
platform. One rule governs the layout — **the kubeconfig is the seam**:

- **Provision** modules (`kind`, `k3d`, `minikube`, future cloud modules) create a cluster and
  their only contract is to output a `kubeconfig`
- **Configure** modules (`git-server`, `flux-operator`) take only a kubeconfig (configured
  `helm`/`kubernetes` providers) and must not reference any substrate or cloud API

Adding a new substrate means a new provision module that outputs a `kubeconfig` matching the
existing ones — nothing above the seam should need to change.

The modules are tool-agnostic: use [OpenTofu](https://opentofu.org/) (the dabba default) or
Terraform.

## Tests and CI

- `tofu fmt -recursive` (or `terraform fmt`) — keep everything formatted
- `tofu validate` each changed module
- End-to-end validation runs in the [dabba](https://github.com/spice-labs-inc/dabba) repo's
  quickstart and local-test harness

## Opening a pull request

- Reference the issue you aligned on, explain why, keep commits focused, ensure CI passes
- Update the module README and the module table in the top-level README for any new variable
  or module

## Licensing

Contributions are under the project's [Apache-2.0 license](LICENSE); by submitting, you agree
to license them under the same terms and confirm you have the right to.

## Community

Spice Labs open-source discussions are on Matrix at
https://matrix.to/#/#spice-labs:matrix.org

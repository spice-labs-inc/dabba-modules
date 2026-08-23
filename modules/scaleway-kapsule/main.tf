# Scaleway Kapsule — dabba's second cloud substrate.
#
# Its contract is the same as every other substrate module: produce a kubeconfig
# for the configuration layer to consume. Everything above that seam (Flux,
# Forgejo, cert-manager, the gitops content) is identical to what runs on kind.
#
# Kapsule differs from EKS in one way that simplifies this module considerably:
# the cluster resource returns a complete kubeconfig with a token in it, so there
# is no exec-auth plumbing and no CLI dependency on the machine using it. The
# trade is that the kubeconfig IS a credential rather than a pointer to one — see
# the note in outputs.tf.

locals {
  # Kapsule requires a private network. Provision one unless given a network to
  # join, so the default path needs no prior Scaleway setup at all.
  create_private_network = var.private_network_id == ""
  private_network_id = local.create_private_network ? (
    scaleway_vpc_private_network.this[0].id
  ) : var.private_network_id
}

resource "scaleway_vpc_private_network" "this" {
  count = local.create_private_network ? 1 : 0

  name   = "${var.name}-network"
  region = var.region
  tags   = var.tags
}

resource "scaleway_k8s_cluster" "this" {
  name    = var.name
  version = var.k8s_version
  cni     = var.cni
  region  = var.region
  tags    = var.tags

  private_network_id = local.private_network_id

  # Remove Kubernetes-created load balancers and volumes on destroy. Without
  # this, tearing the cluster down leaves billable resources behind with nothing
  # pointing at them.
  delete_additional_resources = var.delete_additional_resources

  # Patch upgrades apply themselves inside the window; minor upgrades stay a
  # deliberate act, because a minor bump can move CRD API versions out from
  # under the gitops content.
  auto_upgrade {
    enable                        = true
    maintenance_window_start_hour = 3
    maintenance_window_day        = "sunday"
  }
}

resource "scaleway_k8s_pool" "this" {
  cluster_id = scaleway_k8s_cluster.this.id
  name       = "${var.name}-pool"
  node_type  = var.node_type
  zone       = var.zone
  tags       = var.tags

  size     = var.node_count
  min_size = var.autoscaling ? var.min_node_count : null
  max_size = var.autoscaling ? var.max_node_count : var.node_count

  autoscaling = var.autoscaling
  autohealing = true

  # Roll nodes rather than patch them in place, so a node's disk state can never
  # diverge from the image it claims to be running.
  upgrade_policy {
    max_surge       = 1
    max_unavailable = 0
  }
}

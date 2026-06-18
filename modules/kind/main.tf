locals {
  # One containerd registry-mirror patch per entry in registry_mirrors. Empty by
  # default (no mirrors); a local pull-through cache fills it to speed pulls.
  containerd_patches = [
    for host, endpoint in var.registry_mirrors :
    "[plugins.\"io.containerd.grpc.v1.cri\".registry.mirrors.\"${host}\"]\n  endpoint = [\"${endpoint}\"]"
  ]
}

resource "kind_cluster" "this" {
  name       = var.name
  node_image = "kindest/node:${var.k8s_version}"

  kind_config {
    kind                      = "Cluster"
    api_version               = "kind.x-k8s.io/v1alpha4"
    containerd_config_patches = local.containerd_patches

    node {
      role = "control-plane"

      dynamic "extra_port_mappings" {
        for_each = var.port_mappings
        content {
          container_port = extra_port_mappings.value.container_port
          host_port      = extra_port_mappings.value.host_port
        }
      }
    }

    dynamic "node" {
      for_each = range(var.worker_count)
      content {
        role = "worker"
      }
    }
  }
}

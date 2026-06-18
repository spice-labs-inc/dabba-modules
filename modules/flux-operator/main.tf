# Installs the Flux Operator and a FluxInstance that bootstraps Flux and the
# gitops sync. Unlike hand-creating GitRepository/Kustomization objects with
# kubernetes_manifest (which server-side-validates at plan time and so needs the
# flux CRDs to pre-exist), everything here is helm + core resources sequenced by
# depends_on, so it applies cleanly in a single run against a fresh cluster.

resource "kubernetes_namespace_v1" "flux" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "flux_operator" {
  name       = "flux-operator"
  namespace  = kubernetes_namespace_v1.flux.metadata[0].name
  repository = "oci://ghcr.io/controlplaneio-fluxcd/charts"
  chart      = "flux-operator"
  version    = var.operator_chart_version
  wait       = true
}

# Cluster-describing values, referenced by the Kustomizations in the gitops repo
# via postBuild.substituteFrom. Created before the instance so the values exist
# when reconciliation starts.
resource "kubernetes_config_map_v1" "cluster_vars" {
  metadata {
    name      = "cluster-vars"
    namespace = kubernetes_namespace_v1.flux.metadata[0].name
    annotations = {
      "dabba.spicelabs.io/managed" = "generated from dabba.yaml; do not edit — changes are overwritten by dabba"
    }
  }
  data       = var.cluster_vars
  depends_on = [helm_release.flux_operator]
}

resource "helm_release" "flux_instance" {
  name       = "flux"
  namespace  = kubernetes_namespace_v1.flux.metadata[0].name
  repository = "oci://ghcr.io/controlplaneio-fluxcd/charts"
  chart      = "flux-instance"
  version    = var.instance_chart_version

  values = [yamlencode({
    instance = {
      distribution = {
        version = var.flux_version
      }
      sync = {
        kind = "GitRepository"
        url  = var.gitops_repo_url
        ref  = var.gitops_ref
        path = var.sync_path
      }
    }
  })]

  depends_on = [
    helm_release.flux_operator,
    kubernetes_config_map_v1.cluster_vars,
  ]
}

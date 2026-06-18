# In-cluster Forgejo: the authoritative git source Flux reconciles from. Runs as
# a single pod backed by SQLite (the chart's bundled Postgres/Valkey subcharts
# were removed in v14, so a minimal install needs no external database).
#
# Installed at bootstrap, not via gitops — it hosts the gitops repo, so it can't
# be reconciled from the content it serves (the same reason Flux itself is
# bootstrap-installed).

resource "kubernetes_namespace_v1" "git_server" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "forgejo" {
  name       = "forgejo"
  namespace  = kubernetes_namespace_v1.git_server.metadata[0].name
  repository = "oci://code.forgejo.org/forgejo-helm"
  chart      = "forgejo"
  version    = var.chart_version
  wait       = true
  # code.forgejo.org is a slow registry; give the first (uncached) image pull
  # ample headroom. Warm-cache runs complete in seconds.
  timeout = 1200

  values = [yamlencode(merge({
    replicaCount = 1
    persistence = {
      enabled = var.persistence
    }
    gitea = {
      admin = {
        username = var.admin_username
        password = var.admin_password
        email    = var.admin_email
      }
      config = {
        database = { DB_TYPE = "sqlite3" }
        session  = { PROVIDER = "memory" }
        cache    = { ADAPTER = "memory" }
        queue    = { TYPE = "level" }
        server   = { DISABLE_SSH = true }
        service  = { DISABLE_REGISTRATION = true }
      }
    }
  }, length(local.image_override) == 0 ? {} : { image = local.image_override }))]
}

locals {
  # In-cluster URL of the gitops repo, for the FluxInstance sync to point at.
  service_host = "forgejo-http.${var.namespace}.svc.cluster.local"

  # Forgejo image override. Defaults to the dabba ghcr mirror (a digest-preserving,
  # byte-identical copy of the official image, served fast from ghcr's CDN). The
  # tag is the appVersion form (e.g. 15.0.3); the chart appends -rootless, so
  # rootless stays at the chart default. Override any field for upstream/other.
  image_override = merge(
    var.image_registry == null ? {} : { registry = var.image_registry },
    var.image_repository == null ? {} : { repository = var.image_repository },
    var.image_tag == null ? {} : { tag = var.image_tag },
  )
}

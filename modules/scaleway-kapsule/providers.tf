terraform {
  required_version = ">= 1.6.0"
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = ">= 2.39"
    }
  }
}

# Credentials come from the environment (SCW_ACCESS_KEY, SCW_SECRET_KEY,
# SCW_DEFAULT_PROJECT_ID) or ~/.config/scw/config.yaml, never from variables —
# the same reason the eks module takes no AWS keys. A credential passed as a
# terraform variable ends up in the state file.
provider "scaleway" {
  region = var.region
  zone   = var.zone
}

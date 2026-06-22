terraform {
  required_version = ">= 1.6.0"
  required_providers {
    minikube = {
      source  = "scott-the-programmer/minikube"
      version = ">= 0.3, < 1.0"
    }
  }
}

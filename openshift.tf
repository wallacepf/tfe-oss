resource "kubernetes_namespace" "vaulidate" {
  metadata {
    name = "vaulidate"

    labels = {
      acronym = "oss"
      env     = "dev"
    }

    annotations = {
      project = "vaulidate"
    }

  }
}

resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"

    labels = {
      acronym = "oss"
      env     = "dev"
    }

    annotations = {
      project = "vaulidate"
    }

  }
}

resource "kubernetes_service_account" "vaulidate" {
  metadata {
    name      = "vaulidate"
    namespace = "vaulidate"
  }
}

resource "kubernetes_manifest" "deployment_vaulidate" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind"       = "Deployment"
    "metadata" = {
      "labels" = {
        "app" = "vaulidate"
      }
      "name"      = "vaulidate"
      "namespace" = "vaulidate"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "app" = "vaulidate"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "vaulidate"
          }
        }
        "spec" = {
          "containers" = [
            {
              "image" = "wallacepf/vaulidate:latest"
              "name"  = "vaulidate"
            },
          ]
          "serviceAccountName" = "vaulidate"
        }
      }
    }
  }

  depends_on = [
    kubernetes_service_account.vaulidate,
    kubernetes_namespace.vaulidate
  ]
}

resource "kubernetes_manifest" "service_vaulidate_vaulidate" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "Service"
    "metadata" = {
      "name"      = "vaulidate"
      "namespace" = "vaulidate"
    }
    "spec" = {
      "ports" = [
        {
          "port"       = 8080
          "protocol"   = "TCP"
          "targetPort" = 8080
        },
      ]
      "selector" = {
        "app" = "vaulidate"
      }
    }
  }

  depends_on = [
    kubernetes_manifest.deployment_vaulidate
  ]
}

resource "kubernetes_manifest" "route_vaulidate_validate" {
  manifest = {
    "apiVersion" = "route.openshift.io/v1"
    "kind"       = "Route"
    "metadata" = {
      "name"      = "validate"
      "namespace" = "vaulidate"
    }
    "spec" = {
      "path" = "/"
      "port" = {
        "targetPort" = 8080
      }
      "to" = {
        "kind" = "Service"
        "name" = "vaulidate"
      }
    }
  }
  depends_on = [
    kubernetes_manifest.service_vaulidate_vaulidate
  ]
}

resource "helm_release" "vault" {
  name       = "vault-dev"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  namespace  = "vault"

  set {
    name  = "global.openshift"
    value = "true"
  }

  set {
    name  = "injector.image.repository"
    value = "registry.connect.redhat.com/hashicorp/vault-k8s"
  }

  set {
    name  = "injector.image.tag"
    value = "0.14.0-ubi"
  }

  set {
    name  = "injector.agentImage.repository"
    value = "hashicorp/vault"
  }

  set {
    name  = "injector.agentImage.tag"
    value = "1.8.5-ubi"
  }

  set {
    name  = "server.dev.enabled"
    value = "true"
  }

  set {
    name  = "server.image.repository"
    value = "hashicorp/vault"
  }

  set {
    name  = "server.image.tag"
    value = "1.8.5-ubi"
  }
}

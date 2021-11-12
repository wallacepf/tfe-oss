provider "kubernetes" {
  config_path = "/home/wallace/.kube/config"
  experiments {
    manifest_resource = true
  }
}

provider "helm" {
  kubernetes {
    config_path = "/home/wallace/.kube/config"
  }

}

# terraform backend 사용을 위한 추가 - hostname, organization, workspace
terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "osh-project"

    workspaces {
      name = "k8s-infra_prod_cluster"
    }
  }
}

data "terraform_remote_state" "infra" {
  backend = "remote"

  config = {
    hostname = "app.terraform.io"
    organization = "osh-project"
    workspaces = {
      name = "common-infra_vpc"
    }
  }
}

data "terraform_remote_state" "cluster" {
  backend = "remote"

  config = {
    hostname = "app.terraform.io"
    organization = "osh-project"
    workspaces = {
      name = "k8s-infra_cluster"
    }
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.cluster.outputs.cluster_id
}
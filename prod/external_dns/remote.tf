data "terraform_remote_state" "infra" {
  backend = "local"

  config = {
    path = "../../../vpc-infra/prod/vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "cluster" {
  backend = "local"

  config = {
    path = "../../../k8s-infra/prod/cluster/terraform.tfstate"
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.cluster.outputs.cluster_id
}
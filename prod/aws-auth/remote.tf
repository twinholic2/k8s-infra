# data "terraform_remote_state" "cluster" {
#   backend = "local"

#   config = {
#     path = "../cluster/terraform.tfstate"
#   }
# }

# data "terraform_remote_state" "worker" {
#   backend = "local"

#   config = {
#     path = "../worker/terraform.tfstate"
#   }
# }

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

data "terraform_remote_state" "worker" {
  backend = "remote"

  config = {
    hostname = "app.terraform.io"
    organization = "osh-project"
    workspaces = {
      name = "k8s-infra_worker"
    }
  }
}
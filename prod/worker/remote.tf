# data "terraform_remote_state" "infra" {
#   backend = "local"

#   config = {
#     path = "../../../vpc-infra/prod/vpc/terraform.tfstate"
#   }
# }

# data "terraform_remote_state" "cluster" {
#   backend = "local"

#   config = {
#     path = "../cluster/terraform.tfstate"
#   }
# }

# data "terraform_remote_state" "worker" {
#   backend = "local"

#   config = {
#     path = "../cluster/terraform.tfstate"
#   }
# }

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
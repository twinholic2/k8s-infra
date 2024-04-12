data "terraform_remote_state" "infra" {
  backend = "local"

  config = {
    path = "../../../vpc-infra/prod/vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "cluster" {
  backend = "local"

  config = {
    path = "../cluster/terraform.tfstate"
  }
}

data "terraform_remote_state" "worker" {
  backend = "local"

  config = {
    path = "../cluster/terraform.tfstate"
  }
}
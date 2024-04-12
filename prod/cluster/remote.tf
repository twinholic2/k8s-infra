# data "terraform_remote_state" "infra" {
#       backend = "local"

#   config = {
#     path = "../../../vpc-infra/prod/vpc/terraform.tfstate"
#   }
# }

data "terraform_remote_state" "infra" {
  backend = "remote"

  config = {
    hostname = "app.terraform.io"
    organization = "osh-project"
    workspaces = {
      name = "common-infra_prod_vpc"
    }
  }
}

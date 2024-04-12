data "terraform_remote_state" "infra" {
      backend = "local"

  config = {
    path = "../../../vpc-infra/prod/vpc/terraform.tfstate"
  }
}
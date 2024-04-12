terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.30.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

module "cluster" {
  source = "../../modules/cluster"

  cluster_name = var.cluster_name
  env = var.env
  cluster_version = var.cluster_version
  subnets = concat(
    data.terraform_remote_state.infra.outputs.public_subnet,
    data.terraform_remote_state.infra.outputs.private_subnet
  )

  vpc_id = data.terraform_remote_state.infra.outputs.vpc_id

  tags = {
    Terraform   = "true",
    Owner       = "odark",
    Environment = var.env
  }
 
}
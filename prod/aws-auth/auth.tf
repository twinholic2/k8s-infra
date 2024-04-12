#########################################
# aws-auth 생성
###########################################
# resource "local_file" "aws-auth" {
#   content  = data.template_file.aws-auth.rendered
#   filename = "${path.module}/.output/aws_auth.yaml"
# }
terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.10.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

provider "kubectl" {
  host                   = data.terraform_remote_state.cluster.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.cluster.outputs.cluster_certificate)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false

}

resource "kubectl_manifest" "clustersecert" {
      yaml_body = data.template_file.aws-auth.rendered
}

# data "local_file" "aws-auth-data" {
#   filename = "${path.module}/.output/aws_auth.yaml"
# }


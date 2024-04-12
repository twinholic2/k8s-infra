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

module "worker" {
  source = "../../modules/worker"

  name = "worker"
  cluster_version = var.k8s_version
  cluster_name = data.terraform_remote_state.cluster.outputs.cluster_name
  worker_security_group_id = data.terraform_remote_state.worker.outputs.worker_security_group_id
  instance_type = "t3.medium"
     #ec2 describe-images  --filters "Name=name,Values=amazon-eks-node-*" --query 'Images[*].[ImageId, Name]' --region ap-northeast-2
  # image_id = "ami-0cf0af1d11a0627c5" #amazon-eks-node-1.28-v20240307
  image_id = "ami-07cc8400108193157" #amazon-eks-node-1.28-v20240307
  key_name           = var.key_name
  cluster_certificate = data.terraform_remote_state.cluster.outputs.cluster_certificate
  endpoint = data.terraform_remote_state.cluster.outputs.cluster_endpoint
  

   pre_userdata = var.pre_userdata
  additional_userdata = var.additional_userdata

    asg_desired_capacity = 3
  asg_min_size         = 1
  asg_max_size         = 3 

  subnets = data.terraform_remote_state.infra.outputs.private_subnet

  #worker_additional_policies = []
  kubelet_extra_args = ["node.kubernetes.io/instancegroup=application-${var.workergroup}"]
  #  asg_tags = []
   extra_tags = [{
      "key"                 = "aws-node-termination-handler/managed"
      "value"               = ""
      "propagate_at_launch" = false
   }]

   tags = {
    Terraform   = "true"
    Environment = "prod"
    Owner       = "odark"
   }

   lifecycle_hooks = var.hooks
}
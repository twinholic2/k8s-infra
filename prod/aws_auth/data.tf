data "template_file" "aws-auth" {
  template = file("${path.module}/templates/aws_auth.yaml.tpl")

  vars = {
    rolearn   = data.terraform_remote_state.worker.outputs.arn
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.cluster.outputs.cluster_id
}
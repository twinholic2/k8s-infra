#######################################
# EKS용  IAM Role
#######################################
data "aws_iam_policy_document" "worker-assume-role-doc" {
  statement {
    # sid = "EKSClusterAssumeRole"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


data "template_file" "userdata" {
  template = file("${path.module}/templates/userdata.sh.tpl")

  vars = {
    cluster_name        = var.cluster_name
    # cluster_auth_base64 = data.terraform_remote_state.cluster.outputs.certificate_authority
    # endpoint            = data.terraform_remote_state.cluster.outputs.endpoint
    cluster_auth_base64 = var.cluster_certificate
    endpoint            = var.endpoint


    runtime             = tonumber(var.cluster_version) >= 1.26 ? format("%s=%s",var.container_runtime_prefix, var.container_runtime) : ""

    pre_userdata = var.pre_userdata != "" ? var.pre_userdata : local.worker_group_default["pre_userdata"]
    additional_userdata = var.additional_userdata != "" ? var.additional_userdata : local.worker_group_default["additional_userdata"]
    bootstrap_extra_args     = var.bootstrap_extra_args != "" ? var.bootstrap_extra_args : local.worker_group_default["bootstrap_extra_args"]
    kubelet_extra_args   = var.kubelet_extra_args != "" ? format("%s=%s",var.kubelet_extra_prefix, join(",",var.kubelet_extra_args)) : ""
  }
}
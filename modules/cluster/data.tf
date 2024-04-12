#######################################
# EKS용  IAM Role
#######################################
data "aws_iam_policy_document" "eks-assume-role-doc" {
  statement {
    sid = "EKSClusterAssumeRole"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
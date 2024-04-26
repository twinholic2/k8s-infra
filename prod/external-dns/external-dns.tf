provider "aws" {
  region = "ap-northeast-2"
}

provider "kubernetes" {
  host                   =  data.terraform_remote_state.cluster.outputs.cluster_endpoint
  cluster_ca_certificate =  base64decode(data.terraform_remote_state.cluster.outputs.cluster_certificate)
  token                  =  data.aws_eks_cluster_auth.cluster.token 
}

resource "kubernetes_service_account" "alb_service_account" {
  metadata {
    name = var.name
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.this.arn
    }
  }

  depends_on = [aws_iam_role.this]
}

data "aws_iam_openid_connect_provider" "cluster_provider" {
  # arn = "arn:aws:iam::682935334295:oidc-provider/oidc.eks.ap-northeast-2.amazonaws.com/id/32239BE4C9E47C7C658BB9B219D8DD86"
  arn = data.terraform_remote_state.cluster.outputs.oidc_url
}


resource "aws_iam_role" "this" {
  name = "${var.name}-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Effect = "Allow"
            Principal = {
                Federated = "${data.aws_iam_openid_connect_provider.cluster_provider.arn}"
            }
            Action = "sts:AssumeRoleWithWebIdentity"
            Condition = {
                StringEquals = {
                    "${replace(data.aws_iam_openid_connect_provider.cluster_provider.url, "https://", "")}:sub": "system:serviceaccount:${var.namespace}:${var.sa_name}",
                    "${replace(data.aws_iam_openid_connect_provider.cluster_provider.url, "https://", "")}:aud": "sts.amazonaws.com"
                }
            }
        }
    ]
  })
}


resource "aws_iam_role_policy" "this" {
  name     = "${var.name}-policy"
  role = aws_iam_role.this.id
  policy   = jsonencode({
            "Version": "2012-10-17",
            "Statement": [
                {
                "Effect": "Allow",
                "Action": [
                    "route53:ChangeResourceRecordSets"
                ],
                "Resource": [
                    "arn:aws:route53:::hostedzone/*"
                ]
                },
                {
                "Effect": "Allow",
                "Action": [
                    "route53:ListHostedZones",
                    "route53:ListResourceRecordSets",
                    "route53:ListTagsForResource"
                ],
                "Resource": [
                    "*"
                ]
                }
            ]
    })
}








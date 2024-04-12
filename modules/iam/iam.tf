data "tls_certificate" "this" {
#   url = data.terraform_remote_state.cluster.outputs.oidc_url
    url = var.oidc_url
}

resource "aws_iam_openid_connect_provider" "cluster_provider" {
  client_id_list     = var.client_id_list
  thumbprint_list    = [data.tls_certificate.this.certificates[0].sha1_fingerprint]
  url                = var.oidc_url
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
                Federated = "${aws_iam_openid_connect_provider.cluster_provider.arn}"
            }
            Action = "sts:AssumeRoleWithWebIdentity"
            Condition = {
                StringEquals = {
                    "${replace(aws_iam_openid_connect_provider.cluster_provider.url, "https://", "")}:sub": "system:serviceaccount:${var.namespace}:${var.sa_name}",
                    "${replace(aws_iam_openid_connect_provider.cluster_provider.url, "https://", "")}:aud": "sts.amazonaws.com"
                }
            }
        }
    ]
  })
}


resource "aws_iam_role_policy" "this" {
  name     = "${var.name}-policy"
  role = aws_iam_role.this.id
  policy   = var.policy_document_json
}
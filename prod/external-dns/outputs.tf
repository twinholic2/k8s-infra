output "oidc_provider" {
    value = data.aws_iam_openid_connect_provider.cluster_provider.arn
  
}
output "worker_security_group_id" {
  description = "Security group ID attached to the EKS worker."
  value       = aws_security_group.worker.id
}

output "cluster_certificate" {
  description = "value"
  value = aws_eks_cluster.this.certificate_authority.0.data
}

output "cluster_id" {
    value = aws_eks_cluster.this.id
}

output "cluster_name" {
    value = aws_eks_cluster.this.name
}

output "endpoint" {
  value   = aws_eks_cluster.this.endpoint
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = element(concat(aws_eks_cluster.this[*].identity[*].oidc.0.issuer,[""]),0)
}
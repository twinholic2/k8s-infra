output "worker_security_group_id" {
  description = "Security group ID attached to the EKS worker."
  value       = module.cluster.worker_security_group_id
}

output "cluster_name" {
    value = module.cluster.cluster_name
}

output "cluster_certificate" {
  description = "Cluster's certification for kubernetes provider"
  value       = module.cluster.cluster_certificate
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.cluster.endpoint
}

output "cluster_id" {
  value = module.cluster.cluster_id
  
}

output "org_cluster_id" {
  value = module.cluster.endpoint
  
}

output "oidc_url" {
  description = "OIDC endpoint"
  value       = module.cluster.cluster_oidc_issuer_url
}

# output "cluster_certificate" {
#   description = "value"
#   value = aws_eks_cluster.this.certificate_authority.0.data
# }
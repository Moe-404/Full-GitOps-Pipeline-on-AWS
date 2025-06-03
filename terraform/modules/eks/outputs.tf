output "cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.cluster.id
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.cluster.name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.cluster.endpoint
}

output "cluster_certificate_authority" {
  description = "Base64 encoded certificate data"
  value       = aws_eks_cluster.cluster.certificate_authority[0].data
}

output "node_group_arn" {
  description = "Node group ARN"
  value       = aws_eks_node_group.node_group.arn
}

output "cluster_security_group_id" {
  description = "Security group ID attached to cluster"
  value       = aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider"
  value       = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}
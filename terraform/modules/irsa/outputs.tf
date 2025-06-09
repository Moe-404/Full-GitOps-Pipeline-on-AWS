output "iam_role_arn" {
  description = "ARN of the EFS CSI driver IAM role"
  value       = module.irsa.iam_role_arn
} 
# EFS CSI Driver
data "aws_iam_policy_document" "efs_csi_policy" {
  statement {
    actions = [
      "elasticfilesystem:DescribeAccessPoints",
      "elasticfilesystem:DescribeFileSystems",
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "efs_csi" {
  name_prefix = "efs-csi-driver-"
  policy      = data.aws_iam_policy_document.efs_csi_policy.json
}

module "irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.20"

  role_name             = "efs-csi-driver"
  attach_efs_csi_policy = true
  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
    }
  }
} 
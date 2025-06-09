resource "aws_iam_user" "user-SecMang" {
  name = "AWSUser-secret-manager"
  path = "/GradUser/"

  tags = {
    tag-key = "user-secret-manager"
  }
}

resource "aws_iam_access_key" "sec-man-ak" {
  user = aws_iam_user.user-SecMang.name
}

data "aws_iam_policy_document" "sec-man_ro" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
    resources = ["arn:aws:secretsmanager:${var.region}:${var.account_id}:secret:${var.secret_name}*"]
  }
}
output "secret" {
  value = aws_iam_access_key.sec-man-ak.encrypted_secret
}
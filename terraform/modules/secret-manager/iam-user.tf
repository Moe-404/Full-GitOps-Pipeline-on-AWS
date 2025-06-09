resource "aws_iam_user" "user_SecMang" {
  name = "AWSUser_secret_manager"
  path = "/GradUser/"

  tags = {
    tag-key = "user_secret_manager"
  }
}

resource "aws_iam_access_key" "sec_man_ak" {
  user = aws_iam_user.user_SecMang.name
}

data "aws_iam_policy_document" "sec_man_ro" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
    resources = ["arn:aws:secretsmanager:${var.region}:${var.account_id}:secret:${var.secret_name}*"]
  }
}
resource "aws_iam_policy" "sec_man_policy" {
  name   = "ReadSecretsPolicy"
  policy = data.aws_iam_policy_document.sec_man_ro.json
}
resource "aws_iam_policy_attachment" "attach_policy" {
  name       = "AttachReadSecrets"
  users      = [aws_iam_user.user_SecMang.name]
  policy_arn = aws_iam_policy.sec_man_policy.arn
}
output "access_key_id" {
  value = aws_iam_access_key.sec_man_ak.id
}
output "secret_access_key" {
  value     = aws_iam_access_key.sec_man_ak.secret
  sensitive = true
}
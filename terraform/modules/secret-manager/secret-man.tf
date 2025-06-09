resource "aws_secretsmanager_secret" "SecMang-Grad" {
  name = "AWS-GradProject-Secret"
  description = "This secret contains sensitive information for the DB,Redis Credentials."
  
}
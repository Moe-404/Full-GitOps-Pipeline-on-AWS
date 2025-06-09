resource "aws_secretsmanager_secret" "SecMang_Grad" {
  name = "AWS_GradProject_Secret"
  description = "This secret contains sensitive information for the DB,Redis Credentials."
  
}
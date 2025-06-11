resource "aws_secretsmanager_secret" "mysql" {
  name = "mysql-secret"
}

resource "aws_secretsmanager_secret_version" "mysql_version" {
  secret_id     = aws_secretsmanager_secret.mysql.id
  secret_string = jsonencode({
    username = "root"
    password = "1234"
  })
}

resource "aws_secretsmanager_secret" "redis" {
  name = "redis-secret"
}

resource "aws_secretsmanager_secret_version" "redis_version" {
  secret_id     = aws_secretsmanager_secret.redis.id
  secret_string = jsonencode({
    username = "default"
    password = "1234"
  })
}

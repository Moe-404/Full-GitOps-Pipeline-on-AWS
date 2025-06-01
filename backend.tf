terraform {
  backend "s3" {
    bucket         = "iti-grad-project-state-bucket"
    key            = "terraform/state"
    region         = "us-east-1"
    # dynamodb_table = "terraform-lock-table"
    use_lockfile = true  # Versioning in s3 must be enabled so no need to craete the dynamodb table
    encrypt        = true
    
  }
}
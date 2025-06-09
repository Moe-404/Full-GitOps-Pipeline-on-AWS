output "ecr_repository_url" {
  value = module.ecr.repository_url
}
output "secret_manager_access_key_id" {
  value = module.secret_manager.access_key_id
}

output "secret_manager_secret_access_key" {
  value     = module.secret_manager.secret_access_key
  sensitive = true
}
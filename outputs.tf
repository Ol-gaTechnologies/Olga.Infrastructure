output "resource_group_name" {
  value = module.foundation.resource_group_name
}

output "container_registry" {
  value = module.foundation.acr_login_server
}

output "core_api_url" {
  value = module.platform.core_api_url
}

output "nlp_api_fqdn" {
  value = module.platform.nlp_api_fqdn
}

output "postgres_server_fqdn" {
  value = module.data.postgres_server_fqdn
}

output "key_vault_uri" {
  value = module.data.key_vault_uri
}


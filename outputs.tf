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

output "core_deployment_identity_client_id" {
  description = "Set this as AZURE_CLIENT_ID in the Core repository GitHub environment."
  value       = module.foundation.core_deploy_identity_client_id
}

output "core_deployment_oidc_subject" {
  value = local.core_deploy_oidc_subject
}

output "nlp_deployment_identity_client_id" {
  description = "Set this as AZURE_CLIENT_ID in the NLP repository GitHub environment."
  value       = module.foundation.nlp_deploy_identity_client_id
}

output "nlp_deployment_oidc_subject" {
  value = local.nlp_deploy_oidc_subject
}

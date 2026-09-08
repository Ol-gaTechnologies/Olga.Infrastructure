output "core_api_url" { value = "https://${azurerm_container_app.core_api.latest_revision_fqdn}" }
output "nlp_api_fqdn" { value = azurerm_container_app.nlp_api.latest_revision_fqdn }
output "container_apps_environment_id" { value = azurerm_container_app_environment.this.id }


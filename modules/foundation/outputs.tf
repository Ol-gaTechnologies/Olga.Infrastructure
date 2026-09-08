output "resource_group_name" { value = azurerm_resource_group.this.name }
output "resource_group_id" { value = azurerm_resource_group.this.id }
output "log_analytics_workspace_id" { value = azurerm_log_analytics_workspace.this.id }
output "application_insights_connection_string" {
  value     = azurerm_application_insights.this.connection_string
  sensitive = true
}
output "acr_id" { value = azurerm_container_registry.this.id }
output "acr_login_server" { value = azurerm_container_registry.this.login_server }
output "core_identity_id" { value = azurerm_user_assigned_identity.core.id }
output "core_identity_principal_id" { value = azurerm_user_assigned_identity.core.principal_id }
output "nlp_identity_id" { value = azurerm_user_assigned_identity.nlp.id }
output "nlp_identity_principal_id" { value = azurerm_user_assigned_identity.nlp.principal_id }
output "worker_identity_id" { value = azurerm_user_assigned_identity.worker.id }
output "worker_identity_principal_id" { value = azurerm_user_assigned_identity.worker.principal_id }
output "postgres_admin_password" {
  value     = random_password.postgres_admin.result
  sensitive = true
}

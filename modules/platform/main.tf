resource "azurerm_container_app_environment" "this" {
  name                       = "cae-olga-${var.environment}-${var.suffix}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  infrastructure_subnet_id   = var.container_apps_subnet_id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  tags                       = var.tags
}

resource "azurerm_role_assignment" "core_acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = var.core_identity_principal_id
}

resource "azurerm_role_assignment" "nlp_acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = var.nlp_identity_principal_id
}

resource "azurerm_container_app" "core_api" {
  name                         = "ca-olga-core-api-${var.environment}"
  container_app_environment_id = azurerm_container_app_environment.this.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"
  tags                         = var.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [var.core_identity_id]
  }

  secret {
    name                = "postgresql"
    key_vault_secret_id = var.postgres_connection_secret_uri
    identity            = var.core_identity_id
  }

  secret {
    name                = "service-token"
    key_vault_secret_id = var.service_token_secret_uri
    identity            = var.core_identity_id
  }

  dynamic "registry" {
    for_each = var.use_acr_images ? [1] : []
    content {
      server   = var.acr_login_server
      identity = var.core_identity_id
    }
  }

  template {
    min_replicas = 0
    max_replicas = 2

    container {
      name   = "core-api"
      image  = var.core_api_image
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "ASPNETCORE_ENVIRONMENT"
        value = "Development"
      }
      env {
        name        = "ConnectionStrings__PostgreSql"
        secret_name = "postgresql"
      }
      env {
        name        = "ServiceAuthorization__Token"
        secret_name = "service-token"
      }
      env {
        name  = "APPLICATIONINSIGHTS_CONNECTION_STRING"
        value = var.application_insights_connection_string
      }

      dynamic "liveness_probe" {
        for_each = var.use_acr_images ? [1] : []
        content {
          transport               = "HTTP"
          port                    = 8080
          path                    = "/health"
          initial_delay           = 10
          interval_seconds        = 30
          failure_count_threshold = 3
        }
      }

      dynamic "readiness_probe" {
        for_each = var.use_acr_images ? [1] : []
        content {
          transport               = "HTTP"
          port                    = 8080
          path                    = "/ready"
          initial_delay           = 10
          interval_seconds        = 10
          failure_count_threshold = 6
        }
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = 8080
    transport        = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  depends_on = [azurerm_role_assignment.core_acr_pull]
}

resource "azurerm_container_app" "nlp_api" {
  name                         = "ca-olga-nlp-api-${var.environment}"
  container_app_environment_id = azurerm_container_app_environment.this.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"
  tags                         = var.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [var.nlp_identity_id]
  }

  secret {
    name                = "postgresql"
    key_vault_secret_id = var.postgres_connection_secret_uri
    identity            = var.nlp_identity_id
  }

  secret {
    name                = "service-token"
    key_vault_secret_id = var.service_token_secret_uri
    identity            = var.nlp_identity_id
  }

  dynamic "registry" {
    for_each = var.use_acr_images ? [1] : []
    content {
      server   = var.acr_login_server
      identity = var.nlp_identity_id
    }
  }

  template {
    min_replicas = 0
    max_replicas = 2

    container {
      name   = "nlp-api"
      image  = var.nlp_api_image
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "ASPNETCORE_ENVIRONMENT"
        value = "Development"
      }
      env {
        name        = "ConnectionStrings__PostgreSql"
        secret_name = "postgresql"
      }
      env {
        name        = "ServiceAuthorization__Token"
        secret_name = "service-token"
      }
      env {
        name  = "EmbeddingProvider"
        value = "Fake"
      }
      env {
        name  = "EmbeddingProcessing__Mode"
        value = "Inline"
      }
      env {
        name  = "APPLICATIONINSIGHTS_CONNECTION_STRING"
        value = var.application_insights_connection_string
      }

      dynamic "liveness_probe" {
        for_each = var.use_acr_images ? [1] : []
        content {
          transport               = "HTTP"
          port                    = 8080
          path                    = "/health"
          initial_delay           = 10
          interval_seconds        = 30
          failure_count_threshold = 3
        }
      }

      dynamic "readiness_probe" {
        for_each = var.use_acr_images ? [1] : []
        content {
          transport               = "HTTP"
          port                    = 8080
          path                    = "/ready"
          initial_delay           = 10
          interval_seconds        = 10
          failure_count_threshold = 6
        }
      }
    }
  }

  ingress {
    external_enabled = false
    target_port      = 8080
    transport        = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  depends_on = [azurerm_role_assignment.nlp_acr_pull]
}

resource "azurerm_signalr_service" "this" {
  count = var.enable_signalr ? 1 : 0

  name                          = "sigr-olga-${var.suffix}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  public_network_access_enabled = true
  connectivity_logs_enabled     = true
  messaging_logs_enabled        = true
  service_mode                  = "Default"
  tags                          = var.tags

  sku {
    name     = "Free_F1"
    capacity = 1
  }
}

resource "azurerm_notification_hub_namespace" "this" {
  count = var.enable_notification_hubs ? 1 : 0

  name                = "nhns-olga-${var.suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  namespace_type      = "NotificationHub"
  sku_name            = "Free"
  tags                = var.tags
}

resource "azurerm_notification_hub" "this" {
  count = var.enable_notification_hubs ? 1 : 0

  name                = "nh-olga-${var.environment}"
  namespace_name      = azurerm_notification_hub_namespace.this[0].name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_cognitive_account" "content_safety" {
  count = var.enable_content_safety ? 1 : 0

  name                          = "cs-olga-${var.suffix}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  kind                          = "ContentSafety"
  sku_name                      = "F0"
  custom_subdomain_name         = "cs-olga-${var.suffix}"
  local_auth_enabled            = false
  public_network_access_enabled = true
  tags                          = var.tags
}

resource "azurerm_cognitive_account" "openai" {
  count = var.enable_azure_openai ? 1 : 0

  name                          = "aoai-olga-${var.suffix}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  kind                          = "OpenAI"
  sku_name                      = "S0"
  custom_subdomain_name         = "aoai-olga-${var.suffix}"
  local_auth_enabled            = false
  public_network_access_enabled = true
  tags                          = var.tags
}

resource "azurerm_cognitive_deployment" "embedding" {
  count = var.enable_azure_openai ? 1 : 0

  name                 = "text-embedding-3-small"
  cognitive_account_id = azurerm_cognitive_account.openai[0].id

  model {
    format  = "OpenAI"
    name    = "text-embedding-3-small"
    version = var.azure_openai_model_version
  }

  sku {
    name     = "Standard"
    capacity = 10
  }
}

resource "azurerm_api_management" "this" {
  count = var.enable_api_management ? 1 : 0

  name                = "apim-olga-${var.suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  publisher_name      = var.apim_publisher_name
  publisher_email     = var.apim_publisher_email
  sku_name            = "Consumption_0"
  tags                = var.tags
}

resource "azurerm_static_web_app" "admin" {
  count = var.enable_admin_static_web_app ? 1 : 0

  name                = "stapp-olga-admin-${var.suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_tier            = "Free"
  sku_size            = "Free"
  tags                = var.tags
}


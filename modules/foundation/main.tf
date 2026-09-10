data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = "log-olga-${var.environment}-${var.suffix}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  daily_quota_gb      = 0.1
  tags                = var.tags
}

resource "azurerm_application_insights" "this" {
  name                 = "appi-olga-${var.environment}-${var.suffix}"
  location             = azurerm_resource_group.this.location
  resource_group_name  = azurerm_resource_group.this.name
  workspace_id         = azurerm_log_analytics_workspace.this.id
  application_type     = "web"
  daily_data_cap_in_gb = 0.1
  sampling_percentage  = 20
  tags                 = var.tags
}

resource "azurerm_container_registry" "this" {
  name                = "acrolga${var.suffix}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "Basic"
  admin_enabled       = false
  tags                = var.tags
}

resource "azurerm_user_assigned_identity" "core" {
  name                = "id-olga-core-${var.environment}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  tags                = var.tags
}

resource "azurerm_user_assigned_identity" "nlp" {
  name                = "id-olga-nlp-${var.environment}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  tags                = var.tags
}

resource "azurerm_user_assigned_identity" "worker" {
  name                = "id-olga-worker-${var.environment}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  tags                = var.tags
}

resource "random_password" "postgres_admin" {
  length           = 32
  special          = true
  override_special = "!#%*+-.:=?@_"
}

resource "azurerm_consumption_budget_resource_group" "this" {
  count = length(var.budget_alert_emails) > 0 ? 1 : 0

  name              = "budget-olga-${var.environment}"
  resource_group_id = azurerm_resource_group.this.id
  amount            = var.budget_amount_usd
  time_grain        = "Monthly"

  time_period {
    start_date = formatdate("YYYY-MM-01'T'00:00:00'Z'", timestamp())
    end_date   = "${var.expiry_date}T00:00:00Z"
  }

  dynamic "notification" {
    for_each = toset([50, 80, 100])
    content {
      enabled        = true
      threshold      = notification.value
      operator       = "GreaterThanOrEqualTo"
      threshold_type = "Actual"
      contact_emails = var.budget_alert_emails
    }
  }
}

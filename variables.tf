variable "subscription_id" {
  description = "Azure subscription receiving the OLGA environment."
  type        = string
}

variable "tenant_id" {
  description = "Microsoft Entra tenant containing the Azure subscription."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment must be dev, test, or prod."
  }
}

variable "location" {
  description = "Approved Azure region after service-availability and residency review."
  type        = string
  default     = "malaysiawest"
}

variable "owner" {
  type = string
}

variable "cost_center" {
  type    = string
  default = "olga-connect"
}

variable "expiry_date" {
  description = "ISO date used by development-environment governance."
  type        = string
}

variable "budget_amount_usd" {
  type    = number
  default = 50
}

variable "budget_alert_emails" {
  type    = list(string)
  default = []
}

variable "postgres_admin_username" {
  type    = string
  default = "olga_migration_admin"
}

variable "postgres_sku_name" {
  type    = string
  default = "B_Standard_B1ms"
}

variable "postgres_storage_mb" {
  type    = number
  default = 32768
}

variable "core_api_image" {
  description = "Immutable Core API image. The public bootstrap image allows infrastructure-first provisioning."
  type        = string
  default     = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
}

variable "nlp_api_image" {
  description = "Immutable NLP API image."
  type        = string
  default     = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
}

variable "use_acr_images" {
  description = "Enable after both API images have been pushed to the provisioned ACR."
  type        = bool
  default     = false
}

variable "enable_api_management" {
  type    = bool
  default = false
}

variable "apim_publisher_name" {
  type    = string
  default = "OLGA Connect"
}

variable "apim_publisher_email" {
  type    = string
  default = "platform@example.invalid"
}

variable "enable_admin_static_web_app" {
  type    = bool
  default = false
}

variable "enable_azure_openai" {
  description = "Enable only after regional availability and model quota are approved."
  type        = bool
  default     = false
}

variable "azure_openai_model_version" {
  type    = string
  default = "1"
}

variable "enable_content_safety" {
  type    = bool
  default = false
}

variable "enable_signalr" {
  type    = bool
  default = false
}

variable "enable_notification_hubs" {
  type    = bool
  default = false
}

variable "enable_service_bus" {
  description = "Provision Service Bus Standard only when asynchronous messaging is being tested."
  type        = bool
  default     = false
}

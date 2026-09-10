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
  description = "Core API bootstrap image used when the Container App is created. The Core delivery workflow owns later image revisions."
  type        = string
  default     = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
}

variable "nlp_api_image" {
  description = "NLP API bootstrap image used when the Container App is created. The NLP delivery workflow owns later image revisions."
  type        = string
  default     = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
}

variable "use_acr_images" {
  description = "Compatibility switch that enables ACR delivery for both APIs. Prefer the Core-specific switch for a Core-only release."
  type        = bool
  default     = false
}

variable "core_application_delivery_enabled" {
  description = "Configure Core API for its ACR-hosted .NET image on port 8080."
  type        = bool
  default     = true
}

variable "core_health_probes_enabled" {
  description = "Enable Core liveness (/health) and database-readiness (/ready) probes."
  type        = bool
  default     = true
}

variable "nlp_application_delivery_enabled" {
  description = "Configure NLP API for its ACR-hosted .NET image on port 8080."
  type        = bool
  default     = true
}

variable "nlp_health_probes_enabled" {
  description = "Enable NLP liveness (/health) and database-readiness (/ready) probes."
  type        = bool
  default     = true
}

variable "github_organization_subject" {
  description = "Immutable GitHub organization subject component in NAME@DATABASE_ID format."
  type        = string
  default     = "Ol-gaTechnologies@306667340"

  validation {
    condition     = can(regex("^[^/@]+@[0-9]+$", var.github_organization_subject))
    error_message = "github_organization_subject must use NAME@DATABASE_ID format."
  }
}

variable "core_github_repository_subject" {
  description = "Immutable GitHub Core repository subject component in NAME@DATABASE_ID format."
  type        = string
  default     = "Olga.Core@1358930841"

  validation {
    condition     = can(regex("^[^/@]+@[0-9]+$", var.core_github_repository_subject))
    error_message = "core_github_repository_subject must use NAME@DATABASE_ID format."
  }
}

variable "nlp_github_repository_subject" {
  description = "Immutable GitHub NLP repository subject component in NAME@DATABASE_ID format."
  type        = string
  default     = "olga-nlp-api@1356082344"

  validation {
    condition     = can(regex("^[^/@]+@[0-9]+$", var.nlp_github_repository_subject))
    error_message = "nlp_github_repository_subject must use NAME@DATABASE_ID format."
  }
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

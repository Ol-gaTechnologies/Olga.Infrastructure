locals {
  workload       = "olga"
  suffix         = substr(lower(replace("${var.environment}-${var.location}-${var.subscription_id}", "/[^0-9a-z]/", "")), 0, 16)
  resource_group = "rg-${local.workload}-${var.environment}-${var.location}"
  tags = {
    product     = "olga-connect"
    environment = var.environment
    owner       = var.owner
    costCenter  = var.cost_center
    dataClass   = "confidential"
    expiryDate  = var.expiry_date
    managedBy   = "terraform"
  }
}

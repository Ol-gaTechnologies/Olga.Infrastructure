# OLGA Connect Azure infrastructure

Terraform project for isolated OLGA Connect development, test, and production environments.

## Provisioned baseline

- Resource group, mandatory tags, monthly budget alerts
- Log Analytics and Application Insights
- Azure Container Registry with managed-identity image pulls
- VNet and delegated Container Apps/PostgreSQL subnets
- PostgreSQL 17 Flexible Server, private DNS, 7-day development backup, `vector` and `pg_stat_statements`
- Private Key Vault and Blob Storage with purpose-specific containers
- Service Bus Standard queues with duplicate detection and dead-letter behavior
- Product API with external ingress and NLP API with internal ingress
- Optional SignalR, Notification Hubs, Content Safety, Azure OpenAI, API Management, and Static Web Apps

## Prerequisites

- Terraform 1.9 or later
- Azure CLI authenticated to the target tenant
- An approved Azure subscription and deployment region
- Contributor plus User Access Administrator permissions for the initial deployment
- Remote-state storage bootstrapped once

## First development deployment

```powershell
.\scripts\bootstrap-state.ps1 `
  -SubscriptionId '<subscription-id>' `
  -Location 'malaysiawest' `
  -StorageAccountName '<globally-unique-state-account>' > backend.hcl

Copy-Item .\dev.example.auto.tfvars .\dev.auto.tfvars
# Fill non-secret environment values in dev.auto.tfvars.

terraform init -backend-config=backend.hcl
terraform fmt -recursive
terraform validate
terraform plan -out=dev.tfplan
terraform apply dev.tfplan
```

The first apply uses Microsoft's public Container Apps bootstrap image. After building and pushing the API images, set immutable image references and enable ACR pulls:

```hcl
use_acr_images = true
core_api_image = "<acr>.azurecr.io/olga-core-api:<commit-sha>"
nlp_api_image  = "<acr>.azurecr.io/olga-nlp-api:<commit-sha>"
```

## Database deployment

Run `D:\OLGA\Projects\database\olga-database\deploy.ps1` from a VNet-connected runner because PostgreSQL has no public endpoint. Use the migration administrator only for schema deployment. The current APIs can bootstrap with the generated development connection secret, but workload-identity database authentication is required before test or production.

## Application readiness

- Core API expects port `8080`, `/health`, `/ready`, `ConnectionStrings__PostgreSql`, and `ServiceAuthorization__Token`.
- NLP API expects the same probes and secrets. Development sets `EmbeddingProvider=Fake` and `EmbeddingProcessing__Mode=Inline`.
- Enable Azure OpenAI only after the NLP adapter is implemented and regional model quota is approved.
- API Management is not enabled by default; enable it after the OpenAPI import, OIDC validation, throttling, and policy configuration are defined.


# OLGA Connect Azure infrastructure

Terraform project for isolated OLGA Connect development, test, and production environments.

GitHub Actions validation, planning, deployment, environment setup, and incident guidance are documented in [docs/TERRAFORM_CI_CD.md](docs/TERRAFORM_CI_CD.md).

## Provisioned baseline

- Resource group, mandatory tags, monthly budget alerts
- Log Analytics and Application Insights
- Azure Container Registry with managed-identity image pulls
- VNet and delegated Container Apps/PostgreSQL subnets
- PostgreSQL 17 Flexible Server, private DNS, 7-day development backup, `vector` and `pg_stat_statements`
- Private Key Vault and Blob Storage with purpose-specific containers
- Optional Service Bus Standard queues with duplicate detection and dead-letter behavior
- Product API with external ingress and NLP API with internal ingress
- Optional SignalR, Notification Hubs, Content Safety, Azure OpenAI, API Management, and Static Web Apps

## Prerequisites

- Terraform 1.9 or later
- Azure CLI authenticated to the target tenant
- An approved Azure subscription and deployment region
- Contributor plus User Access Administrator permissions for the initial deployment
- Remote-state storage bootstrapped once

## First development deployment

The checked-in `olga-connect-dev.example.tfvars` file is configured for the `olga-connect-dev` subscription in tenant `9972baa6-9591-43d7-8b13-59da8e6f1a72`. Terraform does not load this example file automatically. For local deployment, copy it to `olga-connect-dev.auto.tfvars`, which Terraform loads automatically and Git ignores.

```powershell
.\scripts\bootstrap-state.ps1 `
  -SubscriptionId 'e0bb013f-a8af-4d60-9c5b-0140b361f257' `
  -Location 'malaysiawest' `
  -StorageAccountName '<globally-unique-state-account>' > backend.hcl

Copy-Item .\olga-connect-dev.example.tfvars .\olga-connect-dev.auto.tfvars
# Fill non-secret environment values in olga-connect-dev.auto.tfvars.

terraform init -backend-config=backend.hcl
terraform fmt -recursive
terraform validate
terraform plan -out=dev.tfplan
terraform apply dev.tfplan
```

The initial dev configuration uses a $50 monthly budget with alerts at 50%, 80%, and 100%; a December 1, 2026 review date; PostgreSQL `B_Standard_B1ms`; 32 GiB database storage; Container Apps scaling from zero to one replica; and 0.1 GB/day telemetry caps. Service Bus, API Management, Static Web Apps, Azure OpenAI, Content Safety, SignalR, and Notification Hubs remain disabled.

The first apply uses Microsoft's public Container Apps bootstrap image. Application repositories own subsequent immutable image revisions; Terraform owns identities, secrets, registry authentication, ingress, and ports. Core and NLP are independently configurable and both use port `8080` by default:

```hcl
core_application_delivery_enabled = true
core_health_probes_enabled         = false
nlp_application_delivery_enabled  = true
nlp_health_probes_enabled          = false
```

The infrastructure apply creates one deployment identity per repository, trusts only that repository's immutable subject for the matching GitHub Environment, grants `AcrPush` on the registry, and grants `Container Apps Contributor` only on the corresponding Container App. After apply, set `core_deployment_identity_client_id` in the Core repository and `nlp_deployment_identity_client_id` in the NLP repository as their respective `AZURE_CLIENT_ID` values.

Run the Core deployment workflow now. The NLP identity and Container App configuration can remain ready until the NLP code is deployed later. Enable each service's health probes only after its real image exposes `/health` and `/ready` on port `8080`.

Do not use application deployment identities for Terraform or at runtime. The Container Apps continue to use `id-olga-core-<environment>` and `id-olga-nlp-<environment>` for ACR pull and Key Vault access.

## Database deployment

Run `D:\OLGA\Projects\database\olga-database\deploy.ps1` from a VNet-connected runner because PostgreSQL has no public endpoint. Use the migration administrator only for schema deployment. The current APIs can bootstrap with the generated development connection secret, but workload-identity database authentication is required before test or production.

## Application readiness

- Core API expects port `8080`, `/health`, `/ready`, `ConnectionStrings__PostgreSql`, and `ServiceAuthorization__Token`.
- NLP API expects the same probes and secrets. Development sets `EmbeddingProvider=Fake` and `EmbeddingProcessing__Mode=Inline`.
- Enable Azure OpenAI only after the NLP adapter is implemented and regional model quota is approved.
- API Management is not enabled by default; enable it after the OpenAPI import, OIDC validation, throttling, and policy configuration are defined.

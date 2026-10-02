# hello-appservice-tf

Terraform that provisions an **Azure App Service (Linux, Python 3.12)** and deploys a Flask
**"Hello world"** app, in three environments: **dev**, **uat** and **prod**. One codebase, one module,
one tfvars file and one state file per environment, promoted by GitHub Actions with approvals.

```
GET /        -> Hello world from DEV!   (UAT!, PROD!)
GET /health  -> {"status": "ok", "env": "dev"}   (App Service health check)
```

## What gets created (per environment)

| Resource | Name | dev | uat | prod |
|---|---|---|---|---|
| Resource group | `rg-hello-<env>` | ✓ | ✓ | ✓ |
| App Service plan (Linux) | `asp-hello-<env>-<rand>` | B1 × 1 | B1 × 1 | **P0v3 × 2** |
| Web app (Python 3.12, gunicorn) | `app-hello-<env>-<rand>` | ✓ | ✓ | ✓ |
| Application Insights + Log Analytics | `appi-…`, `log-…` | 30 days | 30 days | 90 days |
| Diagnostic setting (HTTP, console and app logs) | `diag-app-…` | ✓ | ✓ | ✓ |

The web app enforces HTTPS only and TLS 1.2, has FTP disabled, has HTTP/2 enabled, and gets a system-assigned
managed identity. The health check is `/health`, and `APP_ENV` is set per environment.
`<rand>` is a 4-character suffix stored in each environment's state, so the global web app name stays stable.

## Layout

```
app/                         Flask app (app.py, requirements.txt)
infra/
  providers.tf               azurerm ~> 4.30, partial azurerm backend (Entra auth, no storage keys)
  main.tf                    zips app/, then resource group + module
  modules/python_webapp/     plan, web app, App Insights, Log Analytics, diagnostics
  environments/<env>.tfvars  the ONLY place environments differ (SKU, instances, retention, tags)
  backends/<env>.hcl         separate state file per environment
scripts/bootstrap-state.sh   one-time creation of the state storage account
.github/workflows/           terraform.yml (pipeline) + _terraform-env.yml (plan/apply one env)
```

## How the code is deployed

`main.tf` zips `app/` into `infra/.build/app-<content-hash>.zip` and passes it to the web app's
`zip_deploy_file`. With `SCM_DO_BUILD_DURING_DEPLOYMENT=true`, App Service runs `pip install -r requirements.txt`,
then starts `gunicorn app:app`. When the code changes, the hash and therefore the file name change, and Terraform redeploys.
When it doesn't change, the plan shows no change.

> This keeps "hello world" to a single `terraform apply`. For a real application, let Terraform own only the
> infrastructure and deploy code from the pipeline (`azure/webapps-deploy` or `az webapp deploy`, with deployment slots
> for zero-downtime swaps). Then set `webdeploy_publish_basic_authentication_enabled = false`.

## First-time setup

1. **State storage** (once):
   ```bash
   az login
   bash scripts/bootstrap-state.sh <unique-storage-name> [<pipeline-sp-object-id>]
   ```
   Then put that name in `storage_account_name` in `infra/backends/{dev,uat,prod}.hcl`.

2. **Pipeline identity:** an Entra app registration with **Contributor** on the subscription (it creates
   resource groups) and **Storage Blob Data Contributor** on the state account. Add federated credentials with
   issuer `https://token.actions.githubusercontent.com` and subjects
   `repo:<org>/<repo>:environment:<name>` for each of `dev-plan`, `dev`, `uat-plan`, `uat`, `prod-plan`, `prod`.
   For stricter isolation, use one identity per environment, scoped to that environment's resource group, and set
   `AZURE_CLIENT_ID` on each GitHub environment instead of the repository.

3. **GitHub** (*Settings → Environments / Variables*):

   | Where | Setting |
   |---|---|
   | Repository variables | `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID` |
   | Environments `dev-plan`, `uat-plan`, `prod-plan`, `dev` | no protection rules |
   | Environment `uat` | Required reviewers (QA) |
   | Environment `prod` | Required reviewers (owner), deployment branches: `main` only |

## Pipeline

| Trigger | What runs |
|---|---|
| Pull request | `fmt -check`, `validate`, app smoke test, **plan dev** (in the job summary) |
| Push to `main` | plan → apply **dev** → plan **uat** → ⏸ approval → apply **uat** → plan **prod** → ⏸ approval → apply **prod** |

Each apply runs the **saved plan file** that the approver could read in the plan job's summary, never a new plan.
After each apply, a smoke test polls the URL until it returns "Hello world".

## Running locally

```bash
cd infra
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)    # PowerShell: $env:ARM_SUBSCRIPTION_ID = (az account show --query id -o tsv)
terraform init -backend-config=backends/dev.hcl                   # use -reconfigure when switching env
terraform plan  -var-file=environments/dev.tfvars -out=dev.tfplan
terraform apply dev.tfplan
terraform output url
```

Run the app without Azure: `cd app && pip install -r requirements.txt && flask run` → http://127.0.0.1:5000

Apply UAT and PROD only through the pipeline. To remove an environment: `terraform destroy -var-file=environments/<env>.tfvars`.

## Cost

The App Service plans account for most of the cost: B1 (the cheapest dedicated Linux tier) in dev and uat, and two P0v3
instances (entry Premium v3: deployment slots and autoscale) in prod. Log Analytics charges per GB ingested.
Check current prices in the Azure pricing calculator before applying prod.
To stop paying for dev, run `terraform destroy` on it. The next apply recreates it, but with a **new** random suffix,
so the URL changes.

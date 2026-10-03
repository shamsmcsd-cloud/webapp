# POST Holdings AI Foundry - Monorepo Blueprint

Enterprise-grade monorepo architecture for POST Holdings with three isolated AI Foundry projects, each with dedicated Flask microservices, Terraform infrastructure-as-code, and automated CI/CD pipelines.

## 📋 Overview

This monorepo implements a production-ready architecture with:

- **3 Isolated Projects** - Completely separate codebases within a single repository
- **Independent Infrastructure** - Each project manages its own Azure resources via Terraform
- **Separate State Management** - Terraform state stored independently per project in Azure Storage
- **Path-Based CI/CD** - GitHub Actions workflows triggered only when specific project paths change
- **Access Control** - CODEOWNERS file enforces developer boundaries and approval workflows
- **Flask Web Services** - Python-based microservices returning "Hello World" responses

## 🏗️ Repository Structure

```
POST_Holdings_Monorepo/
├── .github/
│   ├── CODEOWNERS                    # Access control and approval requirements
│   └── workflows/
│       ├── project1-deploy.yml       # CI/CD for Project 1
│       ├── project2-deploy.yml       # CI/CD for Project 2
│       └── project3-deploy.yml       # CI/CD for Project 3
│
├── project1/                         # Project 1 - Isolated
│   ├── app/
│   │   ├── main.py                   # Flask application (Hello World)
│   │   ├── requirements.txt          # Python dependencies
│   │   ├── runtime.txt               # Python version specification
│   │   └── startup.sh                # Azure Web App startup script
│   └── infra/
│       ├── main.tf                   # Azure infrastructure definition
│       ├── variables.tf              # Input variables
│       ├── outputs.tf                # Output values
│       └── terraform.tfvars          # Variable values
│
├── project2/                         # Project 2 - Isolated
│   ├── app/
│   │   ├── main.py
│   │   ├── requirements.txt
│   │   ├── runtime.txt
│   │   └── startup.sh
│   └── infra/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── terraform.tfvars
│
├── project3/                         # Project 3 - Isolated
│   ├── app/
│   │   ├── main.py
│   │   ├── requirements.txt
│   │   ├── runtime.txt
│   │   └── startup.sh
│   └── infra/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── terraform.tfvars
│
├── .gitignore                        # Git ignore patterns
└── README.md                         # This file
```

## 🚀 Quick Start

### Prerequisites

- Git
- Terraform >= 1.0
- Python 3.11
- Azure CLI (authenticated)
- GitHub account with repository admin access

### 1. Clone the Repository

```bash
git clone <repository-url>
cd POST_Holdings_Monorepo
```

### 2. Test Flask Applications Locally

Each project has an identical Flask application structure:

```bash
# Project 1
cd project1/app
pip install -r requirements.txt
python main.py
# Visit http://localhost:8000

# Project 2
cd project2/app
pip install -r requirements.txt
python main.py

# Project 3
cd project3/app
pip install -r requirements.txt
python main.py
```

### 3. Deploy Infrastructure with Terraform

Each project requires separate Terraform deployment:

```bash
# Project 1
cd project1/infra
terraform init
terraform plan
terraform apply

# Repeat for project2 and project3
```

### 4. Configure GitHub Secrets

Add the following secrets to GitHub repository settings:

```
AZURE_CLIENT_ID              # Service Principal ID
AZURE_CLIENT_SECRET          # Service Principal Secret
AZURE_SUBSCRIPTION_ID        # Azure Subscription ID
AZURE_TENANT_ID              # Azure Tenant ID
AZURE_WEBAPP_PUBLISH_PROFILE_PROJECT1  # Web App publish profile
AZURE_WEBAPP_PUBLISH_PROFILE_PROJECT2  # Web App publish profile
AZURE_WEBAPP_PUBLISH_PROFILE_PROJECT3  # Web App publish profile
```

## 🔧 Flask Application Endpoints

Each project exposes the following endpoints:

### Project 1
- `GET /` - Hello World response
- `GET /health` - Health check
- `GET /project1/info` - Project information

### Project 2
- `GET /` - Hello World response
- `GET /health` - Health check
- `GET /project2/info` - Project information

### Project 3
- `GET /` - Hello World response
- `GET /health` - Health check
- `GET /project3/info` - Project information

### Example Response

```json
{
  "message": "Hello World from Project 1",
  "project": "project1",
  "environment": "dev",
  "version": "1.0.0"
}
```

## 🛡️ Project Isolation Benefits

### No Cross-Project Impact
- Changes in Project 1 don't affect Projects 2 or 3
- Each project has its own resource group and web app

### Independent Deployment
- Project 1 can deploy without waiting for Project 2 or 3
- CI/CD pipelines trigger only when that project's files change

### Terraform State Isolation
- Each project manages separate Terraform state in Azure Storage
- No state lock conflicts between projects
- Safe concurrent deployments

### Access Control
- CODEOWNERS file enforces approval requirements
- Developers must get project lead approval for changes
- Clear responsibility boundaries

## 📝 CI/CD Pipeline Details

### Pipeline Triggers

Each workflow only runs when changes affect its project:

```yaml
paths:
  - 'project1/**'           # Trigger only for Project 1 changes
  - '.github/workflows/project1-deploy.yml'  # OR workflow file changes
```

### Pipeline Stages

1. **Build & Test**
   - Set up Python environment
   - Install dependencies
   - Run linting and basic tests
   - Verify Flask app imports correctly

2. **Terraform Plan**
   - Initialize Terraform
   - Validate Terraform configuration
   - Check formatting

3. **Deploy** (main branch only)
   - Deploy Flask app to Azure Web App
   - Uses isolated publish profile

## 🔐 Terraform Backend Configuration

### Azure Storage Setup

Required Azure Storage Account:

```
Resource Group: tfstate-rg
Storage Account: tfstateprod
Containers:
  - project1  (key: project1.tfstate)
  - project2  (key: project2.tfstate)
  - project3  (key: project3.tfstate)
```

### Authentication

Terraform uses Service Principal authentication:

```bash
export ARM_CLIENT_ID="<client-id>"
export ARM_CLIENT_SECRET="<client-secret>"
export ARM_SUBSCRIPTION_ID="<subscription-id>"
export ARM_TENANT_ID="<tenant-id>"
```

## 📊 Project Configuration

### Terraform Variables

Each project's `terraform.tfvars`:

```hcl
resource_group_name   = "projectX-rg"
location              = "eastus"
environment           = "dev"      # dev, uat, prod
app_service_plan_name = "projectX-asp"
web_app_name          = "projectX-webapp-postholdings"
sku_name              = "B1"       # B1, B2, B3, S1, P1V2, etc.
```

## 🔄 Development Workflow

### Making Changes to Project 1

```bash
# Create a branch
git checkout -b feature/project1-enhancement

# Make changes to project1/
vim project1/app/main.py
vim project1/infra/main.tf

# Commit and push
git add project1/
git commit -m "Feature: Add new endpoint to Project 1"
git push origin feature/project1-enhancement

# Create Pull Request
# - CODEOWNERS automatically reviews Project 1 changes
# - CI/CD pipeline tests Project 1 only
# - After approval, merge to main
# - Deployment workflow runs automatically
```

### Critical Guidelines

- **Never** modify files in other projects without explicit reason
- **Always** test locally before pushing
- **Request** approvals from CODEOWNERS before merging
- **Review** Terraform plan before applying changes

## 📈 Scaling Considerations

### Adding More Projects

1. Create new `projectN/` directory
2. Copy `project1/` as template
3. Update resource names and identifiers
4. Create new workflow file `.github/workflows/projectN-deploy.yml`
5. Add entries to `.github/CODEOWNERS`
6. Create new Terraform state container in Azure Storage

### Environment Expansion

Current setup supports: `dev`, `uat`, `prod`

To add environments, modify `terraform.tfvars` for each environment:

```bash
project1/infra/terraform.tfvars.dev
project1/infra/terraform.tfvars.uat
project1/infra/terraform.tfvars.prod
```

## 🐛 Troubleshooting

### Pipeline Failures

1. **Check GitHub Actions logs**: Repository → Actions → Failed workflow
2. **Verify Azure credentials**: Ensure AZURE_* secrets are set correctly
3. **Terraform errors**: Review `/project*/infra/` for syntax issues
4. **Flask import errors**: Verify `requirements.txt` includes all dependencies

### Terraform State Issues

```bash
# View current state
terraform state list

# Backup state before changes
terraform state pull > backup.tfstate

# Refresh state if out of sync
terraform refresh
```

### Web App Deployment

```bash
# Check deployment logs
az webapp deployment log tail --name project1-webapp-postholdings \
  --resource-group project1-rg

# Restart web app
az webapp restart --name project1-webapp-postholdings \
  --resource-group project1-rg
```

## 🔗 Useful Commands

### Local Testing

```bash
# Run Flask app
cd project1/app && python main.py

# Test endpoint
curl http://localhost:8000/
curl http://localhost:8000/health
curl http://localhost:8000/project1/info
```

### Terraform Operations

```bash
# Validate configuration
terraform validate

# Format code
terraform fmt -recursive

# Show plan
terraform plan -out=tfplan

# Apply changes
terraform apply tfplan

# Destroy resources
terraform destroy
```

### Azure CLI Operations

```bash
# List resource groups
az group list

# View Web App details
az webapp show --name project1-webapp-postholdings --resource-group project1-rg

# Stream logs
az webapp log tail --name project1-webapp-postholdings --resource-group project1-rg
```

## 📚 Best Practices

1. **Always use feature branches** for development
2. **Never commit secrets** (use GitHub Secrets)
3. **Test Terraform locally** before pushing
4. **Review CODEOWNERS approvals** before merging
5. **Monitor CI/CD pipelines** for failures
6. **Keep dependencies updated** in `requirements.txt`
7. **Document infrastructure changes** in commit messages
8. **Use consistent naming conventions** across projects
9. **Regularly back up Terraform state** files
10. **Tag releases** when deploying to production

## 📞 Support & Collaboration

- **Repository Owner**: Shams (@shams-dev)
- **Team Lead**: @team-lead
- **Issues**: Use GitHub Issues for bug reports
- **Discussions**: Use GitHub Discussions for architecture decisions

## 📄 License

Proprietary - POST Holdings

## 🙏 Acknowledgments

This monorepo blueprint follows enterprise DevOps best practices for:
- Terraform infrastructure isolation
- GitHub Actions CI/CD automation
- Azure cloud deployment patterns
- Python microservices architecture

---

**Last Updated**: October 2, 2026

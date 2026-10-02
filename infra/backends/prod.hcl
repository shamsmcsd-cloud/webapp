# terraform init -backend-config=backends/prod.hcl   (create the storage with scripts/bootstrap-state.sh first)
resource_group_name  = "rg-hello-tfstate"
storage_account_name = "<tfstate-storage-account>"
container_name       = "tfstate"
key                  = "hello-appservice/prod.tfstate"
use_azuread_auth     = true

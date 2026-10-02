# terraform init -backend-config=backends/uat.hcl   (create the storage with scripts/bootstrap-state.sh first)
resource_group_name  = "rg-hello-tfstate"
storage_account_name = "<tfstate-storage-account>"
container_name       = "tfstate"
key                  = "hello-appservice/uat.tfstate"
use_azuread_auth     = true

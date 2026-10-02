#!/usr/bin/env bash
# One-time: create the storage account that holds Terraform state for dev/uat/prod,
# and let the pipeline identity read/write it with Entra ID (no storage keys).
#
# Usage: scripts/bootstrap-state.sh <storage-account-name> [pipeline-principal-object-id]
set -euo pipefail

SA="${1:?globally unique storage account name, 3-24 lowercase letters/digits}"
PRINCIPAL_ID="${2:-}"
RG="rg-hello-tfstate"
LOCATION="centralus"

az group create --name "$RG" --location "$LOCATION" --output none
az storage account create --name "$SA" --resource-group "$RG" --location "$LOCATION" \
  --sku Standard_GRS --kind StorageV2 --min-tls-version TLS1_2 \
  --allow-blob-public-access false --allow-shared-key-access false --output none
az storage account blob-service-properties update --account-name "$SA" --resource-group "$RG" \
  --enable-versioning true --enable-delete-retention true --delete-retention-days 30 --output none
az storage container create --name tfstate --account-name "$SA" --auth-mode login --output none

SA_ID=$(az storage account show --name "$SA" --resource-group "$RG" --query id -o tsv)
ME=$(az ad signed-in-user show --query id -o tsv)
az role assignment create --assignee-object-id "$ME" --assignee-principal-type User \
  --role "Storage Blob Data Contributor" --scope "$SA_ID" --output none
if [ -n "$PRINCIPAL_ID" ]; then
  az role assignment create --assignee-object-id "$PRINCIPAL_ID" --assignee-principal-type ServicePrincipal \
    --role "Storage Blob Data Contributor" --scope "$SA_ID" --output none
fi

echo "Done. Put storage_account_name = \"$SA\" in infra/backends/{dev,uat,prod}.hcl"

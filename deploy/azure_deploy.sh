#!/bin/bash

# Azure Cloud Deployment - Full-Stack Enterprise RAG
set -e

echo "======================================================"
echo " Starting Azure Cloud Full-Stack Deployment "
echo "======================================================"

# 1. Load Environment Variables
if [ -f "../demo/.env" ]; then
    export $(grep -v '^#' ../demo/.env | xargs)
    echo "[OK] Loaded cloud credentials from demo/.env"
else
    echo "[ERR] demo/.env not found. Please copy .env.example and fill it first."
    exit 1
fi

# 2. Configuration
RANDOM_ID=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 5 | head -n 1)
RESOURCE_GROUP="rg-enterprise-rag-${RANDOM_ID}"
LOCATION="eastus"
ACR_NAME="acrenterpriserag${RANDOM_ID}"

echo "Target Resource Group: ${RESOURCE_GROUP}"
echo "Target Region: ${LOCATION}"

# 3. Azure Login Check
echo "[1/5] Verifying Azure Authentication..."
az account show > /dev/null || az login

# 4. Infrastructure Preparation
echo "[2/5] Initializing Resource Group & Container Registry..."
az group create --name "${RESOURCE_GROUP}" --location "${LOCATION}"
az acr create --resource-group "${RESOURCE_GROUP}" --name "${ACR_NAME}" --sku Basic --admin-enabled true
ACR_SERVER=$(az acr show --name "${ACR_NAME}" --query loginServer -o tsv)

# 5. Build & Deploy Backend First (To get FQDN)
echo "[3/5] Building & Deploying Backend API..."
az acr build --registry "${ACR_NAME}" --image backend:latest ../backend

# Deployment Stage 1: Backend only
BACKEND_OUT=$(az deployment group create \
  --resource-group "${RESOURCE_GROUP}" \
  --template-file ../infra/main.bicep \
  --parameters \
    backendImage="${ACR_SERVER}/backend:latest" \
    containerRegistryName="${ACR_NAME}" \
    azureOpenAiKey="${AZURE_OPENAI_API_KEY}" \
    azureSearchEndpoint="${AZURE_SEARCH_ENDPOINT}" \
    azureSearchKey="${AZURE_SEARCH_KEY:-""}" \
  --query properties.outputs -o json)

BACKEND_URL=$(echo $BACKEND_OUT | jq -r .backendUrl.value)
echo "[OK] Backend deployed at: ${BACKEND_URL}"

# 6. Build & Deploy Frontend (Injected with Backend URL)
echo "[4/5] Building & Deploying Frontend UI..."
# Use ACR Build with Build Args for Vite environment injection
az acr build --registry "${ACR_NAME}" \
  --image frontend:latest \
  --build-arg VITE_API_URL="${BACKEND_URL}" \
  ../frontend

# Deployment Stage 2: Full Stack
FINAL_OUT=$(az deployment group create \
  --resource-group "${RESOURCE_GROUP}" \
  --template-file ../infra/main.bicep \
  --parameters \
    backendImage="${ACR_SERVER}/backend:latest" \
    frontendImage="${ACR_SERVER}/frontend:latest" \
    containerRegistryName="${ACR_NAME}" \
    azureOpenAiKey="${AZURE_OPENAI_API_KEY}" \
    azureSearchEndpoint="${AZURE_SEARCH_ENDPOINT}" \
    azureSearchKey="${AZURE_SEARCH_KEY:-""}" \
  --query properties.outputs -o json)

FRONTEND_URL=$(echo $FINAL_OUT | jq -r .frontendUrl.value)

echo ""
echo "======================================================"
echo " [SUCCESS] Cloud Deployment Complete!"
echo "======================================================"
echo " Access your Azure-hosted RAG System at:"
echo " ${FRONTEND_URL}"
echo "======================================================"
echo ""
read -p "Have you finished evaluating the Azure deployment? Releasing resources now prevents any accidental cloud costs. Teardown now? (y/n): " teardown_confirm

if [[ "$teardown_confirm" =~ ^[Yy]$ ]]; then
    echo ""
    bash ./azure_teardown.sh "${RESOURCE_GROUP}"
else
    echo ""
    echo "[!] Resources kept active. Manual teardown required later:"
    echo "    bash ./azure_teardown.sh ${RESOURCE_GROUP}"
    echo "======================================================"
fi

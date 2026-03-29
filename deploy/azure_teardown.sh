#!/bin/bash

# Azure Cloud Teardown - Full-Stack Enterprise RAG
set -e

RESOURCE_GROUP=$1

if [ -z "$RESOURCE_GROUP" ]; then
    echo "Usage: ./azure_teardown.sh <RESOURCE_GROUP_NAME>"
    exit 1
fi

echo "======================================================"
echo " Starting Azure Cloud Cleanup: ${RESOURCE_GROUP} "
echo "======================================================"

# 1. Azure Login Check
echo "[1/2] Verifying Azure Authentication..."
az account show > /dev/null || az login

# 2. Delete Resource Group
echo "[2/2] Deleting Resource Group (This may take a few minutes)..."
az group delete --name "${RESOURCE_GROUP}" --yes --no-wait

echo ""
echo "======================================================"
echo " [SUCCESS] Cleanup initiated!"
echo "======================================================"
echo " Resources are being decommissioned in the background."
echo " Final confirmation can be seen in the Azure Portal."
echo "======================================================"

#!/bin/bash

# Deployment script for Lokka MCP Server to Azure Container Apps
# Make sure to set these variables first:

# Replace these with your actual values
REGISTRY_NAME="cglokkareg"
RESOURCE_GROUP="Devon_Streelman_test"
LOCATION="westus3"
CONTAINER_APP_NAME="cg-lokka-mcp-server"
ENVIRONMENT_NAME="lokka-mcp-env"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting Lokka MCP deployment...${NC}"

# Check if Azure CLI is logged in
if ! az account show &> /dev/null; then
    echo -e "${RED}Error: Please login to Azure CLI first with 'az login'${NC}"
    exit 1
fi

# Step 1: Create Azure Container Registry (if it doesn't exist)
echo -e "${YELLOW}Creating Azure Container Registry...${NC}"
az acr create \
    --resource-group $RESOURCE_GROUP \
    --name $REGISTRY_NAME \
    --sku Basic \
    --location $LOCATION \
    --admin-enabled true

# Step 2: Build and push container
echo -e "${YELLOW}Building and pushing container...${NC}"
az acr build \
    --registry $REGISTRY_NAME \
    --image lokka-mcp:latest \
    .

# Step 3: Create Container App Environment
echo -e "${YELLOW}Creating Container App Environment...${NC}"
az containerapp env create \
    --name $ENVIRONMENT_NAME \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION

# Step 4: Deploy Container App
echo -e "${YELLOW}Deploying Container App...${NC}"
az containerapp create \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --environment $ENVIRONMENT_NAME \
    --image ${REGISTRY_NAME}.azurecr.io/lokka-mcp:latest \
    --registry-server ${REGISTRY_NAME}.azurecr.io \
    --min-replicas 0 \
    --max-replicas 3 \
    --cpu 0.5 \
    --memory 1.0Gi \
    --env-vars \
        TENANT_ID=secretref:tenant-id \
        CLIENT_ID=secretref:client-id \
        CLIENT_SECRET=secretref:client-secret \
        USE_GRAPH_BETA=true \
        HOME=/home/lokka

echo -e "${RED}IMPORTANT: You need to set the secrets manually:${NC}"
echo "az containerapp secret set --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP --secrets"
echo "  tenant-id=YOUR_TENANT_ID"
echo "  client-id=YOUR_CLIENT_ID" 
echo "  client-secret=YOUR_CLIENT_SECRET"

# Get the app URL
APP_URL=$(az containerapp show \
    --name $CONTAINER_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --query properties.configuration.ingress.fqdn \
    -o tsv)

echo -e "${GREEN}Deployment complete!${NC}"
echo -e "${GREEN}Container App URL: https://$APP_URL${NC}"
echo -e "${YELLOW}Don't forget to set the secrets as shown above!${NC}"
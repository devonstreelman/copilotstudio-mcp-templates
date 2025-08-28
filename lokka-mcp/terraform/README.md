# Lokka MCP Server Terraform Deployment

This Terraform configuration deploys a complete Lokka MCP server infrastructure on Azure, including:

- Azure Container Registry
- Azure Container Apps Environment
- Azure Container App running Lokka MCP with HTTP transport
- Log Analytics Workspace
- Optional Azure AD App Registration

## Prerequisites

1. **Azure CLI** installed and authenticated:
   ```bash
   az login
   ```

2. **Terraform** installed (version 1.0+)

3. **Docker** installed for building container images

4. **Azure AD Application** (either existing or let Terraform create one):
   - Microsoft Graph API permissions
   - Client secret

## Quick Start

1. **Clone and prepare**:
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Configure variables** in `terraform.tfvars`:
   ```hcl
   tenant_id     = "your-tenant-id"
   client_id     = "your-client-id" 
   client_secret = "your-client-secret"
   registry_name = "youruniqueregistry123"
   ```

3. **Deploy infrastructure**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Build and deploy container**:
   ```bash
   # Get the build command from Terraform output
   terraform output build_command
   
   # Execute the build command (example):
   az acr build --registry lokkamcpreg --image lokka-mcp:http-native . --file Dockerfile.lokka-http-clean --resource-group lokka-mcp-rg
   ```

5. **Get service URLs**:
   ```bash
   terraform output lokka_mcp_url      # Main service URL
   terraform output mcp_endpoint_url   # MCP endpoint for Copilot Studio
   terraform output health_check_url   # Health check endpoint
   ```

## Configuration Options

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `tenant_id` | Azure AD Tenant ID | `12345678-1234-1234-1234-123456789012` |
| `client_id` | Azure AD Application ID | `87654321-4321-4321-4321-210987654321` |
| `client_secret` | Azure AD Application Secret | `your-secret-value` |

### Optional Variables

| Variable | Description | Default | 
|----------|-------------|---------|
| `location` | Azure region | `West US 3` |
| `prefix` | Resource name prefix | `lokka-mcp` |
| `registry_name` | Container registry name (globally unique) | `lokkamcpreg` |
| `create_app_registration` | Create new Azure AD app | `false` |

## Outputs

After deployment, Terraform provides these useful outputs:

- `lokka_mcp_url` - Main service URL
- `mcp_endpoint_url` - MCP endpoint for Copilot Studio integration  
- `health_check_url` - Health check endpoint
- `build_command` - Command to build and push container image

## Azure AD App Registration

### Option 1: Use Existing App Registration
Set `create_app_registration = false` and provide existing credentials:
```hcl
tenant_id     = "your-tenant-id"
client_id     = "your-existing-app-id"
client_secret = "your-existing-secret"
```

### Option 2: Let Terraform Create App Registration
Set `create_app_registration = true`:
```hcl
create_app_registration = true
tenant_id = "your-tenant-id"
# client_id and client_secret will be created automatically
```

## Required Azure AD Permissions

The Azure AD application needs these Microsoft Graph permissions:

- **Application Permissions** (Admin consent required):
  - `Directory.ReadWrite.All`
  - `Group.ReadWrite.All`
  
- **Delegated Permissions**:
  - `User.Read`

## Container Image Building

The Terraform doesn't automatically build the container image. After infrastructure deployment:

1. Get the build command:
   ```bash
   terraform output build_command
   ```

2. Execute from the project root:
   ```bash
   az acr build --registry yourregistry --image lokka-mcp:http-native . --file Dockerfile.lokka-http-clean --resource-group your-rg
   ```

3. The Container App will automatically deploy the new image.

## Copilot Studio Integration

Use the MCP endpoint URL from Terraform output:
```bash
terraform output mcp_endpoint_url
```

Example: `https://lokka-mcp-server.region.azurecontainerapps.io/mcp`

## Monitoring and Troubleshooting

### Health Check
```bash
curl $(terraform output -raw health_check_url)
```

### Test MCP Endpoint
```bash
curl -X POST $(terraform output -raw mcp_endpoint_url) \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -d '{"jsonrpc":"2.0","method":"tools/list","id":1}'
```

### View Logs
```bash
az containerapp logs show --name $(terraform output -raw container_app_name) --resource-group $(terraform output -raw resource_group_name)
```

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

## Cost Optimization

- Container Apps scale to zero when not in use
- Basic Container Registry for development
- 30-day log retention
- Consumption-based pricing

## Security Considerations

- All secrets stored in Azure Container Apps secrets
- HTTPS-only ingress
- Container registry with admin access (consider using managed identity for production)
- Network security groups can be added for additional protection

## Production Recommendations

1. **Use Azure Key Vault** for secret management
2. **Enable managed identity** instead of registry admin access
3. **Configure custom domain** and SSL certificates
4. **Set up monitoring** and alerting
5. **Implement backup** and disaster recovery
6. **Use Premium Container Registry** for production workloads
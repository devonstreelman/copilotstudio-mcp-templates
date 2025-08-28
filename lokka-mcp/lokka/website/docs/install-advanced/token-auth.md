---
title: 🔑 Token auth
sidebar_position: 4
slug: /install-advanced/token-auth
---

With token auth, the user provides a valid Microsoft Graph access token to the Lokka agent. This method is useful in dev scenarios where you want to use an existing token from the Azure CLI or another tool like Graph Explorer.

Configure the Lokka agent to use token auth by setting the `USE_CLIENT_TOKEN` environment variable to `true`.

```json
{
    "Lokka-Microsoft": {
      "command": "npx",
      "args": ["-y", "@merill/lokka"],
      "env": {
        "USE_CLIENT_TOKEN": "true"
      }
    }
}
```

When using client-provided token mode:

1. Start the MCP server with `USE_CLIENT_TOKEN=true`
2. Use the `set-access-token` tool to provide a valid Microsoft Graph access token (Press # in chat and type the `set` to see the tools that start with `set-`)
3. Use the `get-auth-status` tool to verify authentication status
4. Refresh tokens as needed using `set-access-token`

## Getting tokens

You can obtain a valid Microsoft Graph access token using the Azure CLI, Graph PowerShell or Graph Explorer.

This method is useful for development and testing purposes, but it is not recommended for production use due to security concerns.

In addition, access token are short-lived (typically 1 hour) and will need to be refreshed periodically.

### Option 1: Graph Explorer

1. Go to [Graph Explorer](https://aka.ms/ge)
2. Sign in with your Microsoft account
3. Select the **Access token** tab in the top pane below the URL bar

#### To add additional permissions to the token

1. Click on the **Modify permissions** button
2. Search for the permissions you want to add (e.g. `User.Read.All`)
3. Click **Add permissions**
4. Click **Consent on behalf of your organization** to grant admin consent for the permissions
5. Copy the access token from the **Access token** tab

### Option 2: Azure CLI

```bash
# Login to Azure CLI
az login

# Get a token for Microsoft Graph
az account get-access-token --resource https://graph.microsowft.com --query accessToken -o tsv
```

### Option 3: Graph PowerShell

```powershell
# Login to Graph PowerShell
Connect-MgGraph

# Get a token for Microsoft Graph
$data = Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/v1.0/me" -Method GET -OutputType HttpResponseMessage
$data.RequestMessage.Headers.Authorization.Parameter

```

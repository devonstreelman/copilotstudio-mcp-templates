# How to Start Lokka MCP Server Locally and Test Microsoft Graph

This guide shows you how to start the Lokka MCP Server locally and test it with real Microsoft Graph API requests.

## Prerequisites

1. **Node.js** installed (v16 or later)
2. **Valid Microsoft Graph access token** (see below for how to get one)
3. **Build the project**: `npm run build`

## Getting an Access Token

### Option 1: Azure CLI (Easiest)

```bash
# Login to Azure CLI
az login

# Get a token for Microsoft Graph
az account get-access-token --resource https://graph.microsowft.com --query accessToken -o tsv
```

### Option 2: Graph Explorer (Quick Testing)

1. Go to https://developer.microsoft.com/en-us/graph/graph-explorer
2. Sign in with your Microsoft account
3. Open browser developer tools (F12)
4. Go to Network tab
5. Make any Graph request (like GET /me)
6. Find the request in Network tab
7. Copy the Authorization header value (remove "Bearer " prefix)

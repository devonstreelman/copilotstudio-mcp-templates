output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.lokka_mcp.name
}

output "container_registry_login_server" {
  description = "Login server URL for the container registry"
  value       = azurerm_container_registry.lokka_mcp.login_server
}

output "container_registry_name" {
  description = "Name of the container registry"
  value       = azurerm_container_registry.lokka_mcp.name
}

output "container_app_name" {
  description = "Name of the container app"
  value       = azurerm_container_app.lokka_mcp.name
}

output "container_app_fqdn" {
  description = "FQDN of the container app"
  value       = azurerm_container_app.lokka_mcp.ingress[0].fqdn
}

output "lokka_mcp_url" {
  description = "Public URL for the Lokka MCP server"
  value       = "https://${azurerm_container_app.lokka_mcp.ingress[0].fqdn}"
}

output "health_check_url" {
  description = "Health check endpoint URL"
  value       = "https://${azurerm_container_app.lokka_mcp.ingress[0].fqdn}/health"
}

output "mcp_endpoint_url" {
  description = "MCP endpoint URL for Copilot Studio"
  value       = "https://${azurerm_container_app.lokka_mcp.ingress[0].fqdn}/mcp"
}

output "build_command" {
  description = "Command to build and push the container image"
  value = "az acr build --registry ${azurerm_container_registry.lokka_mcp.name} --image ${var.image_name}:${var.image_tag} . --file Dockerfile.lokka-http-clean --resource-group ${azurerm_resource_group.lokka_mcp.name}"
}

output "app_registration_client_id" {
  description = "Client ID of the created Azure AD application (if created)"
  value       = var.create_app_registration ? azuread_application.lokka_mcp[0].client_id : null
}

output "app_registration_client_secret" {
  description = "Client secret of the created Azure AD application (if created)"
  value       = var.create_app_registration ? azuread_application_password.lokka_mcp[0].value : null
  sensitive   = true
}
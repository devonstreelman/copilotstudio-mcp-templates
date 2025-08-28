variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "UPDATE_RESOURCE_GROUP_NAME"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "UPDATE_AZURE_REGION"
}

variable "prefix" {
  description = "Prefix for all resources"
  type        = string
  default     = "UPDATE_RESOURCE_PREFIX"
}

variable "registry_name" {
  description = "Name of the container registry (must be globally unique)"
  type        = string
  default     = "UPDATE_REGISTRY_NAME"
}

variable "image_name" {
  description = "Name of the container image"
  type        = string
  default     = "lokka-mcp"
}

variable "image_tag" {
  description = "Tag of the container image"
  type        = string
  default     = "http-clean"
}

variable "tenant_id" {
  description = "Azure AD Tenant ID"
  type        = string
  default     = "UPDATE_TENANT_ID"
  sensitive   = true
}

variable "client_id" {
  description = "Azure AD Application (client) ID"
  type        = string
  default     = "UPDATE_CLIENT_ID"
  sensitive   = true
}

variable "client_secret" {
  description = "Azure AD Application client secret"
  type        = string
  default     = "UPDATE_CLIENT_SECRET"
  sensitive   = true
}

variable "create_app_registration" {
  description = "Whether to create a new Azure AD app registration"
  type        = bool
  default     = false
}

variable "key_vault_name" {
  description = "Name of the Azure Key Vault (must be globally unique)"
  type        = string
  default     = "UPDATE_KEY_VAULT_NAME"
}
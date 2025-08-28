variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "lokka-mcp-rg"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "West US 3"
}

variable "prefix" {
  description = "Prefix for all resources"
  type        = string
  default     = "lokka-mcp"
}

variable "registry_name" {
  description = "Name of the container registry (must be globally unique)"
  type        = string
  default     = "lokkamcpreg"
}

variable "image_name" {
  description = "Name of the container image"
  type        = string
  default     = "lokka-mcp"
}

variable "image_tag" {
  description = "Tag of the container image"
  type        = string
  default     = "http-native"
}

variable "tenant_id" {
  description = "Azure AD Tenant ID"
  type        = string
  sensitive   = true
}

variable "client_id" {
  description = "Azure AD Application (client) ID"
  type        = string
  sensitive   = true
}

variable "client_secret" {
  description = "Azure AD Application client secret"
  type        = string
  sensitive   = true
}

variable "create_app_registration" {
  description = "Whether to create a new Azure AD app registration"
  type        = bool
  default     = false
}
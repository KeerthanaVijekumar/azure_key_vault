variable app_name {
  default = "flixtubeazurekeyvault"
}

variable location {
  default = "australiasoutheast"
}

variable kubernetes_version {  
  default = "1.30.2"  
}

# Define variables to store Azure credentials
variable "client_id" {
  type = string
  description = "The Client ID (Application ID) for Azure authentication."
}

variable "client_secret" {
  type = string
  description = "The Client Secret for Azure authentication."
}

variable "subscription_id" {
  type = string
  description = "The Subscription ID for Azure authentication."
}

variable "tenant_id" {
  type = string
  description = "The Tenant ID for Azure authentication."
}
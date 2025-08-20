variable "subscription_id" {
  type = string
}

variable "regions" {
  description = "List of regions to create resources in. First is primary."
  type        = list(string)
  default     = ["eastus", "westus2"]
}

variable "project_prefix" {
  type    = string
  default = "drdemo"
}

variable "tags" {
  type = map(string)
  default = {
    owner       = "devops"
    environment = "dr-demo"
  }
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "sql_admin" {
  type    = string
  default = "sqladmin"
}

variable "sql_password" {
  type      = string
  sensitive = true
}

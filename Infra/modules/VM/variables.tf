variable "prefix" { type = string }
variable "name_suffix" { type = string } # region or index
variable "location" { type = string }
variable "resource_group" { type = string }
variable "subnet_id" { type = string }
variable "size" {
  type    = string
  default = "Standard_B2s"
}
variable "admin_username" { type = string }
variable "admin_password" {
  type      = string
  sensitive = true
}
variable "custom_data" {
  type    = string
  default = ""
}
variable "tags" { type = map(string) }

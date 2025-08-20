variable "region_id" { type = string }
variable "location" { type = string }
variable "resource_group" { type = string }
variable "prefix" { type = string }
variable "address_space" { type = string }
variable "subnet_prefix" { type = string }
variable "tags" { type = map(string) }
variable "service_endpoints" {
  type    = list(string)
  default = []
}

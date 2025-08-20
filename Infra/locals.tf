locals {
  # regions map for easier for_each indexing
  region_map = { for r in var.regions : r => { location = r } }

  naming = {
    prefix = var.project_prefix
  }

  # primary & dr region
  primary_region = var.regions[0]
  
  dr_region      = length(var.regions) > 1 ? var.regions[1] : var.regions[0]
}

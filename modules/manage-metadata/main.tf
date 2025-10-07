# Manage Metadata Module - Catalog and Glossaries

# Catalog Service
module "catalog" {
  count  = var.enable_catalog ? 1 : 0
  source = "./services/catalog"

  project_id   = var.project_id
  region       = var.region
  location     = var.location
  entry_groups = var.entry_groups
  labels       = var.labels
}

# Glossaries Service
module "glossaries" {
  count  = var.enable_glossaries ? 1 : 0
  source = "./services/glossaries"

  project_id  = var.project_id
  region      = var.region
  location    = var.location
  glossaries  = var.glossaries
  labels      = var.labels
}

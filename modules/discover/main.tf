# Discover Module - Search, Taxonomy, Templates

# Search Service
module "search" {
  count  = var.enable_search ? 1 : 0
  source = "./services/search"

  project_id          = var.project_id
  region              = var.region
  location            = var.location
  search_scope        = var.search_scope
  search_result_limit = var.search_result_limit
  labels              = var.labels
}

# Taxonomy Service
module "taxonomy" {
  count  = var.enable_taxonomy ? 1 : 0
  source = "./services/taxonomy"

  project_id            = var.project_id
  region                = var.region
  location              = var.location
  taxonomy_display_name = var.taxonomy_display_name
  policy_tags           = var.policy_tags
  labels                = var.labels
}

# Templates Service
module "templates" {
  count  = var.enable_templates ? 1 : 0
  source = "./services/templates"

  project_id = var.project_id
  region     = var.region
  location   = var.location
  labels     = var.labels
}

# Dataplex Universal Catalog - Root Module
# Orchestrates all feature modules with toggles

# Discover Module - Search, Taxonomy, Templates
module "discover" {
  count  = var.enable_discover ? 1 : 0
  source = "./modules/discover"

  project_id            = var.project_id
  region                = var.region
  location              = var.location
  enable_search         = var.discover_config.enable_search
  enable_taxonomy       = var.discover_config.enable_taxonomy
  enable_templates      = var.discover_config.enable_templates
  search_scope          = var.discover_config.search_scope
  search_result_limit   = var.discover_config.search_result_limit
  taxonomy_display_name = var.discover_config.taxonomy_display_name
  policy_tags           = var.discover_config.policy_tags
  labels                = var.labels
}

# Manage Metadata Module - Catalog, Glossaries
module "manage_metadata" {
  count  = var.enable_manage_metadata ? 1 : 0
  source = "./modules/manage-metadata"

  project_id         = var.project_id
  region             = var.region
  location           = var.location
  enable_catalog     = var.manage_metadata_config.enable_catalog
  enable_glossaries  = var.manage_metadata_config.enable_glossaries
  entry_groups       = var.manage_metadata_config.entry_groups
  glossaries         = var.manage_metadata_config.glossaries
  labels             = var.labels
}

# Manage Lakes Module - Manage, Secure, Process
module "manage_lakes" {
  count  = var.enable_manage_lakes ? 1 : 0
  source = "./modules/manage-lakes"

  project_id      = var.project_id
  region          = var.region
  location        = var.location
  enable_manage   = var.manage_lakes_config.enable_manage
  enable_secure   = var.manage_lakes_config.enable_secure
  enable_process  = var.manage_lakes_config.enable_process
  lakes           = var.manage_lakes_config.lakes
  iam_bindings    = var.manage_lakes_config.iam_bindings
  spark_jobs      = var.manage_lakes_config.spark_jobs
  labels          = var.labels
}

# Govern Module - Profiling, Quality, Monitoring
module "govern" {
  count  = var.enable_govern ? 1 : 0
  source = "./modules/govern"

  project_id        = var.project_id
  region            = var.region
  location          = var.location
  enable_profiling  = var.govern_config.enable_profiling
  enable_quality    = var.govern_config.enable_quality
  enable_monitoring = var.govern_config.enable_monitoring
  quality_scans     = var.govern_config.quality_scans
  profiling_scans   = var.govern_config.profiling_scans
  labels            = var.labels
}

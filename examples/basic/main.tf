# Basic Example - Minimal Dataplex Universal Catalog Setup

module "dataplex" {
  source = "../.."

  project_id = var.project_id
  region     = var.region
  location   = var.location

  # Enable only basic features
  enable_discover        = true
  enable_manage_metadata = true
  enable_manage_lakes    = true
  enable_govern          = false # Disable for basic setup

  # Basic discover configuration
  discover_config = {
    enable_search    = true
    enable_taxonomy  = true
    enable_templates = true
    policy_tags      = ["Confidential", "Public", "Internal"]
  }

  # Basic metadata configuration
  manage_metadata_config = {
    enable_catalog    = true
    enable_glossaries = true
    entry_groups = [
      {
        entry_group_id = "customer-data"
        display_name   = "Customer Data Entry Group"
        description    = "Entry group for customer-related data assets"
      }
    ]
  }

  # Basic lake configuration
  manage_lakes_config = {
    enable_manage  = true
    enable_secure  = false # Disable for basic setup
    enable_process = false # Disable for basic setup
    lakes = [
      {
        lake_id      = "analytics-lake"
        display_name = "Analytics Lake"
        description  = "Lake for analytics and reporting data"
        zones = [
          {
            zone_id      = "raw-zone"
            type         = "RAW"
            display_name = "Raw Data Zone"
          },
          {
            zone_id      = "curated-zone"
            type         = "CURATED"
            display_name = "Curated Data Zone"
          }
        ]
      }
    ]
  }

  labels = {
    environment = "dev"
    managed_by  = "terraform"
    project     = "dataplex-basic"
  }
}

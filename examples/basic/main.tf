# Basic Example - Direct Module Usage
# This example shows how to use individual Dataplex modules directly

# =============================================================================
# MANAGE LAKES MODULE
# =============================================================================
module "manage_lakes" {
  source = "../../modules/manage-lakes"

  project_id = var.project_id
  region     = var.region
  location   = var.location

  enable_manage  = true
  enable_secure  = true
  enable_process = true

  # Define a simple lake with bronze and silver zones
  lakes = [
    {
      lake_id      = "analytics-lake"
      display_name = "Analytics Lake"
      description  = "Basic data lake for analytics"

      zones = [
        {
          zone_id       = "bronze-zone"
          type          = "RAW"
          display_name  = "Bronze Zone"
          description   = "Raw data landing zone"
          location_type = "SINGLE_REGION"
        },
        {
          zone_id       = "silver-zone"
          type          = "CURATED"
          display_name  = "Silver Zone"
          description   = "Curated data zone"
          location_type = "SINGLE_REGION"
        }
      ]
    }
  ]

  # Basic IAM binding
  iam_bindings = [
    {
      lake_id = "analytics-lake"
      role    = "roles/dataplex.viewer"
      members = [
        "group:data-analysts@example.com"
      ]
    }
  ]

  labels = {
    environment = "development"
    managed_by  = "terraform"
  }
}

# =============================================================================
# MANAGE METADATA MODULE
# =============================================================================
module "manage_metadata" {
  source = "../../modules/manage-metadata"

  project_id = var.project_id
  region     = var.region
  location   = var.location

  enable_catalog    = true
  enable_glossaries = false

  # Basic entry groups
  entry_groups = [
    {
      entry_group_id = "customer-data"
      display_name   = "Customer Data"
      description    = "Customer information and analytics"
    },
    {
      entry_group_id = "product-data"
      display_name   = "Product Data"
      description    = "Product catalog"
    }
  ]

  labels = {
    environment = "development"
    managed_by  = "terraform"
  }
}

# =============================================================================
# GOVERN MODULE
# =============================================================================
module "govern" {
  source = "../../modules/govern"

  project_id = var.project_id
  region     = var.region
  location   = var.location

  enable_profiling  = true
  enable_quality    = true
  enable_monitoring = true

  # Basic quality scan
  quality_scans = [
    {
      scan_id      = "customer-quality"
      lake_id      = "analytics-lake"
      display_name = "Customer Quality Check"
      description  = "Basic data quality validation"
      data_source  = "//bigquery.googleapis.com/projects/${var.project_id}/datasets/customers/tables/customer_master"

      rules = [
        {
          rule_type  = "NON_NULL"
          column     = "customer_id"
          threshold  = 1.0
          dimension  = "COMPLETENESS"
        },
        {
          rule_type  = "UNIQUENESS"
          column     = "customer_id"
          threshold  = 1.0
          dimension  = "UNIQUENESS"
        }
      ]
    }
  ]

  # Basic profiling scan
  profiling_scans = [
    {
      scan_id      = "customer-profile"
      lake_id      = "analytics-lake"
      display_name = "Customer Data Profile"
      description  = "Statistical profiling"
      data_source  = "//bigquery.googleapis.com/projects/${var.project_id}/datasets/customers/tables/customer_master"
    }
  ]

  labels = {
    environment = "development"
    managed_by  = "terraform"
  }

  depends_on = [module.manage_lakes]
}

# Basic Example - Using Root Module
# This example shows how to use the unified Dataplex module

# =============================================================================
# UNIFIED DATAPLEX MODULE
# =============================================================================
module "dataplex" {
  source = "../.."

  project_id = var.project_id
  region     = var.region
  location   = var.location

  # Enable or disable features
  enable_manage_lakes = true
  enable_metadata     = true
  enable_governance   = true

  # Lake management settings
  enable_manage  = true
  enable_secure  = true
  enable_process = false # Disable Spark jobs for basic example

  # Metadata settings
  enable_catalog     = true
  enable_glossaries  = false # Disable glossaries for basic example

  # Governance settings
  enable_profiling  = true
  enable_quality    = true
  enable_monitoring = false # Disable monitoring for basic example

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
}

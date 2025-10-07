# Complete Example - Full Dataplex Universal Catalog Setup

module "dataplex" {
  source = "../.."

  project_id = var.project_id
  region     = var.region
  location   = var.location

  # Enable all features
  enable_discover        = true
  enable_manage_metadata = true
  enable_manage_lakes    = true
  enable_govern          = true

  # Complete discover configuration
  discover_config = {
    enable_search         = true
    enable_taxonomy       = true
    enable_templates      = true
    search_scope          = "PROJECT"
    search_result_limit   = 100
    taxonomy_display_name = "Enterprise Data Taxonomy"
    policy_tags = [
      "Highly-Confidential",
      "Confidential",
      "Internal",
      "Public",
      "PII",
      "PCI",
      "PHI",
      "Financial-Data"
    ]
  }

  # Complete metadata configuration
  manage_metadata_config = {
    enable_catalog    = true
    enable_glossaries = true
    entry_groups = [
      {
        entry_group_id = "customer-data"
        display_name   = "Customer Data"
        description    = "Customer information and analytics"
      },
      {
        entry_group_id = "product-data"
        display_name   = "Product Data"
        description    = "Product catalog and inventory"
      },
      {
        entry_group_id = "financial-data"
        display_name   = "Financial Data"
        description    = "Financial transactions and reporting"
      }
    ]
    glossaries = [
      {
        glossary_id  = "business-glossary"
        display_name = "Business Glossary"
        description  = "Enterprise business terminology"
        terms = [
          {
            term_id      = "customer"
            display_name = "Customer"
            description  = "An individual or organization that purchases products or services"
          },
          {
            term_id      = "revenue"
            display_name = "Revenue"
            description  = "Income generated from business operations"
          }
        ]
      }
    ]
  }

  # Complete lakes configuration
  manage_lakes_config = {
    enable_manage  = true
    enable_secure  = true
    enable_process = true
    lakes = [
      {
        lake_id      = "analytics-lake"
        display_name = "Analytics Lake"
        description  = "Central data lake for analytics and ML"
        labels = {
          domain = "analytics"
        }
        zones = [
          {
            zone_id       = "raw-zone"
            type          = "RAW"
            display_name  = "Raw Data Zone"
            description   = "Landing zone for raw data"
            location_type = "SINGLE_REGION"
          },
          {
            zone_id       = "curated-zone"
            type          = "CURATED"
            display_name  = "Curated Data Zone"
            description   = "Processed and validated data"
            location_type = "SINGLE_REGION"
          }
        ]
      },
      {
        lake_id      = "operational-lake"
        display_name = "Operational Lake"
        description  = "Lake for operational and transactional data"
        labels = {
          domain = "operations"
        }
        zones = [
          {
            zone_id       = "ops-raw"
            type          = "RAW"
            display_name  = "Operational Raw Zone"
            location_type = "SINGLE_REGION"
          }
        ]
      }
    ]
    iam_bindings = [
      {
        lake_id = "analytics-lake"
        role    = "roles/dataplex.viewer"
        members = [
          "group:data-analysts@example.com"
        ]
      },
      {
        lake_id = "analytics-lake"
        role    = "roles/dataplex.editor"
        members = [
          "group:data-engineers@example.com"
        ]
      }
    ]
    spark_jobs = [
      {
        job_id       = "data-transformation"
        lake_id      = "analytics-lake"
        display_name = "Data Transformation Job"
        description  = "Transform raw data to curated format"
        main_class   = "com.example.DataTransformation"
        main_jar_uri = "gs://your-bucket/jars/transformation.jar"
        args         = ["--input=raw", "--output=curated"]
      }
    ]
  }

  # Complete governance configuration
  govern_config = {
    enable_profiling  = true
    enable_quality    = true
    enable_monitoring = true
    quality_scans = [
      {
        scan_id      = "customer-quality-scan"
        lake_id      = "analytics-lake"
        display_name = "Customer Data Quality Scan"
        description  = "Quality checks for customer data"
        data_source  = "//bigquery.googleapis.com/projects/${var.project_id}/datasets/customers"
        rules = [
          {
            rule_type  = "NON_NULL"
            column     = "customer_id"
            threshold  = 1.0
            dimension  = "COMPLETENESS"
          },
          {
            rule_type  = "UNIQUENESS"
            column     = "email"
            threshold  = 0.99
            dimension  = "UNIQUENESS"
          },
          {
            rule_type  = "RANGE"
            column     = "age"
            threshold  = 0.95
            dimension  = "VALIDITY"
          }
        ]
      }
    ]
    profiling_scans = [
      {
        scan_id      = "customer-profile-scan"
        lake_id      = "analytics-lake"
        display_name = "Customer Data Profile"
        description  = "Profile customer data characteristics"
        data_source  = "//bigquery.googleapis.com/projects/${var.project_id}/datasets/customers"
      },
      {
        scan_id      = "product-profile-scan"
        lake_id      = "analytics-lake"
        display_name = "Product Data Profile"
        description  = "Profile product data characteristics"
        data_source  = "//bigquery.googleapis.com/projects/${var.project_id}/datasets/products"
      }
    ]
  }

  labels = {
    environment = "production"
    managed_by  = "terraform"
    project     = "dataplex-enterprise"
    cost_center = "data-platform"
  }

  tags = {
    compliance = "gdpr"
    criticality = "high"
  }
}

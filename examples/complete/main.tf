# Complete Example - Production-Ready Configuration
# This example demonstrates all features of the Dataplex modules

# =============================================================================
# MANAGE LAKES MODULE - Full Configuration
# =============================================================================
module "manage_lakes" {
  source = "../../modules/manage-lakes"

  project_id = var.project_id
  region     = var.region
  location   = var.location

  enable_manage  = true
  enable_secure  = true
  enable_process = true

  # Multiple lakes with comprehensive zone configuration
  lakes = [
    {
      lake_id      = "analytics-lake"
      display_name = "Analytics Data Lake"
      description  = "Central lake for analytics and ML workloads"
      labels = {
        domain      = "analytics"
        criticality = "high"
      }

      zones = [
        {
          zone_id       = "raw-zone"
          type          = "RAW"
          display_name  = "Raw Data Zone"
          description   = "Landing zone for raw data ingestion"
          location_type = "SINGLE_REGION"
        },
        {
          zone_id       = "curated-zone"
          type          = "CURATED"
          display_name  = "Curated Data Zone"
          description   = "Cleaned and validated data"
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
          description   = "Operational data landing"
          location_type = "SINGLE_REGION"
        }
      ]
    }
  ]

  # Comprehensive IAM configuration
  iam_bindings = [
    {
      lake_id = "analytics-lake"
      role    = "roles/dataplex.viewer"
      members = [
        "group:data-analysts@example.com",
        "group:data-scientists@example.com"
      ]
    },
    {
      lake_id = "analytics-lake"
      role    = "roles/dataplex.editor"
      members = [
        "group:data-engineers@example.com"
      ]
    },
    {
      lake_id = "operational-lake"
      role    = "roles/dataplex.viewer"
      members = [
        "group:operations-team@example.com"
      ]
    }
  ]

  # Spark jobs for data processing
  spark_jobs = [
    {
      job_id       = "bronze-to-silver-etl"
      lake_id      = "analytics-lake"
      display_name = "Bronze to Silver ETL"
      description  = "Transform raw data to curated format"
      main_class   = "com.example.BronzeToSilverETL"
      main_jar_uri = "gs://my-bucket/jars/etl.jar"
      args         = ["--source=bronze", "--target=silver"]
    },
    {
      job_id       = "data-quality-pipeline"
      lake_id      = "analytics-lake"
      display_name = "Data Quality Pipeline"
      description  = "Run data quality checks"
      main_class   = "com.example.DataQuality"
      main_jar_uri = "gs://my-bucket/jars/quality.jar"
      args         = ["--lake=analytics-lake"]
    }
  ]

  labels = {
    environment = "production"
    managed_by  = "terraform"
    team        = "data-platform"
  }
}

# =============================================================================
# MANAGE METADATA MODULE - Full Configuration
# =============================================================================
module "manage_metadata" {
  source = "../../modules/manage-metadata"

  project_id = var.project_id
  region     = var.region
  location   = var.location

  enable_catalog    = true
  enable_glossaries = true

  # Comprehensive entry groups
  entry_groups = [
    {
      entry_group_id = "customer-data"
      display_name   = "Customer Data Assets"
      description    = "Customer information, profiles, and behavior data"
    },
    {
      entry_group_id = "product-data"
      display_name   = "Product Catalog"
      description    = "Product information, inventory, and pricing"
    },
    {
      entry_group_id = "financial-data"
      display_name   = "Financial Data"
      description    = "Revenue, transactions, and financial reporting"
    },
    {
      entry_group_id = "ml-models"
      display_name   = "ML Models"
      description    = "Machine learning models and predictions"
    }
  ]

  # Business glossaries with terms
  glossaries = [
    {
      glossary_id  = "business-glossary"
      display_name = "Enterprise Business Glossary"
      description  = "Standardized business terminology"

      terms = [
        {
          term_id      = "customer"
          display_name = "Customer"
          description  = "Individual or organization that purchases products or services"
        },
        {
          term_id      = "revenue"
          display_name = "Revenue"
          description  = "Total income generated from business operations"
        },
        {
          term_id      = "churn"
          display_name = "Customer Churn"
          description  = "Rate at which customers discontinue service"
        },
        {
          term_id      = "ltv"
          display_name = "Lifetime Value (LTV)"
          description  = "Predicted net profit from entire future relationship with customer"
        },
        {
          term_id      = "arr"
          display_name = "Annual Recurring Revenue (ARR)"
          description  = "Value of recurring revenue normalized to a one-year period"
        }
      ]
    },
    {
      glossary_id  = "technical-glossary"
      display_name = "Technical Glossary"
      description  = "Technical and data engineering terms"

      terms = [
        {
          term_id      = "data-lake"
          display_name = "Data Lake"
          description  = "Centralized repository for storing structured and unstructured data"
        },
        {
          term_id      = "etl"
          display_name = "ETL (Extract, Transform, Load)"
          description  = "Process of extracting, transforming, and loading data"
        }
      ]
    }
  ]

  labels = {
    environment = "production"
    managed_by  = "terraform"
    team        = "data-platform"
  }
}

# =============================================================================
# GOVERN MODULE - Full Configuration
# =============================================================================
module "govern" {
  source = "../../modules/govern"

  project_id = var.project_id
  region     = var.region
  location   = var.location

  enable_profiling  = true
  enable_quality    = true
  enable_monitoring = true

  # Comprehensive quality scans
  quality_scans = [
    {
      scan_id      = "customer-quality"
      lake_id      = "analytics-lake"
      display_name = "Customer Data Quality"
      description  = "Comprehensive customer data validation"
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
        },
        {
          rule_type  = "REGEX"
          column     = "email"
          threshold  = 0.98
          dimension  = "VALIDITY"
        },
        {
          rule_type  = "RANGE"
          column     = "age"
          threshold  = 0.95
          dimension  = "VALIDITY"
        }
      ]
    },
    {
      scan_id      = "product-quality"
      lake_id      = "analytics-lake"
      display_name = "Product Data Quality"
      description  = "Product catalog validation"
      data_source  = "//bigquery.googleapis.com/projects/${var.project_id}/datasets/products/tables/product_catalog"

      rules = [
        {
          rule_type  = "NON_NULL"
          column     = "product_id"
          threshold  = 1.0
          dimension  = "COMPLETENESS"
        },
        {
          rule_type  = "NON_NULL"
          column     = "price"
          threshold  = 1.0
          dimension  = "COMPLETENESS"
        }
      ]
    }
  ]

  # Comprehensive profiling scans
  profiling_scans = [
    {
      scan_id      = "customer-profile"
      lake_id      = "analytics-lake"
      display_name = "Customer Data Profile"
      description  = "Statistical profiling of customer data"
      data_source  = "//bigquery.googleapis.com/projects/${var.project_id}/datasets/customers/tables/customer_master"
    },
    {
      scan_id      = "product-profile"
      lake_id      = "analytics-lake"
      display_name = "Product Data Profile"
      description  = "Statistical profiling of product catalog"
      data_source  = "//bigquery.googleapis.com/projects/${var.project_id}/datasets/products/tables/product_catalog"
    },
    {
      scan_id      = "transaction-profile"
      lake_id      = "analytics-lake"
      display_name = "Transaction Data Profile"
      description  = "Statistical profiling of transactions"
      data_source  = "//bigquery.googleapis.com/projects/${var.project_id}/datasets/transactions/tables/daily_transactions"
    }
  ]

  labels = {
    environment = "production"
    managed_by  = "terraform"
    team        = "data-platform"
  }

  depends_on = [module.manage_lakes]
}

# Example: Using EXISTING GCS Buckets and BigQuery Datasets with Catalog
module "dataplex" {
  source = "../.."

  project_id = var.project_id
  region     = var.region
  location   = var.location

  enable_manage_lakes = true
  enable_metadata     = true
  enable_governance   = true

  # Manage Lakes settings
  enable_manage  = true
  enable_secure  = false # Disable security features (audit, KMS, service accounts)
  enable_process = false # Disable Spark processing jobs

  # Metadata settings
  enable_catalog    = true
  enable_glossaries = true

  # Governance settings
  enable_quality    = true
  enable_profiling  = true
  enable_monitoring = false

  lakes = [
    {
      lake_id      = "existing-insurance-lake"
      display_name = "Existing Insurance Data Lake"
      zones = [
        # RAW Zone 1: Claims Data
        {
          zone_id         = "claims-raw-zone"
          type            = "RAW"
          existing_bucket = "acrwe-claims-data-lake"
        },
        # RAW Zone 2: Policy Data
        {
          zone_id         = "policy-raw-zone"
          type            = "RAW"
          existing_bucket = "acrwe-policy-data-warehouse"
        },
        # RAW Zone 3: Customer Analytics (GCS)
        {
          zone_id         = "customer-raw-zone"
          type            = "RAW"
          existing_bucket = "acrwe-customer-analytics"
        },
        # RAW Zone 4: Test RAW zone with BigQuery dataset (NEW FEATURE)
        {
          zone_id          = "raw-structured-zone"
          type             = "RAW"
          display_name     = "RAW Zone with BigQuery Dataset"
          existing_dataset = "acrwe_analytics_warehouse"
        },
        # CURATED Zone 1: Claims Analytics
        {
          zone_id          = "claims-analytics-zone"
          type             = "CURATED"
          existing_dataset = "acrwe_claims_analytics"
        },
        # CURATED Zone 2: Policy Underwriting
        {
          zone_id          = "policy-underwriting-zone"
          type             = "CURATED"
          existing_dataset = "acrwe_policy_underwriting"
        },
        # CURATED Zone 3: Customer Insights
        {
          zone_id          = "customer-insights-zone"
          type             = "CURATED"
          existing_dataset = "acrwe_customer_insights"
        },
        # CURATED Zone 4: Analytics Warehouse
        {
          zone_id          = "analytics-warehouse-zone"
          type             = "CURATED"
          existing_dataset = "acrwe_analytics_warehouse"
        },
        # CURATED Zone 5: ML Feature Store
        {
          zone_id          = "ml-feature-store-zone"
          type             = "CURATED"
          existing_dataset = "acrwe_ml_feature_store"
        },
        # CURATED Zone 6: Test CURATED zone with GCS bucket (NEW FEATURE)
        {
          zone_id         = "curated-parquet-zone"
          type            = "CURATED"
          display_name    = "CURATED Zone with GCS Bucket (Parquet)"
          existing_bucket = "acrwe-policy-data-warehouse"
        }
      ]
    }
  ]

  # Entry groups for catalog organization
  entry_groups = [
    {
      entry_group_id = "insurance-claims-data"
      display_name   = "Insurance Claims Data"
      description    = "Entry group for claims-related datasets and assets"
    },
    {
      entry_group_id = "insurance-policy-data"
      display_name   = "Insurance Policy Data"
      description    = "Entry group for policy underwriting datasets"
    },
    {
      entry_group_id = "customer-analytics-data"
      display_name   = "Customer Analytics Data"
      description    = "Entry group for customer insights and analytics"
    }
  ]

  # Business glossaries
  glossaries = [
    {
      glossary_id  = "insurance-business-terms"
      display_name = "Insurance Business Glossary"
      description  = "Standard business terms for insurance domain"
      terms = [
        {
          term_id      = "claim"
          display_name = "Claim"
          description  = "A formal request by a policyholder to an insurance company for coverage or compensation"
        },
        {
          term_id      = "premium"
          display_name = "Premium"
          description  = "The amount paid by the policyholder to the insurance company for coverage"
        },
        {
          term_id      = "underwriting"
          display_name = "Underwriting"
          description  = "The process of evaluating risk and determining insurance policy terms"
        },
        {
          term_id      = "deductible"
          display_name = "Deductible"
          description  = "The amount the policyholder must pay out-of-pocket before insurance coverage begins"
        }
      ]
    }
  ]

  # Data Quality Scans
  quality_scans = [
    {
      scan_id      = "claims-data-quality"
      lake_id      = "existing-insurance-lake"
      display_name = "Claims Data Quality Scan"
      description  = "Data quality checks for claims master table"
      data_source  = "//bigquery.googleapis.com/projects/${var.project_id}/datasets/acrwe_claims_analytics/tables/claims_master"
      rules = [
        {
          rule_type = "NON_NULL"
          column    = "claim_id"
          threshold = 1.0
          dimension = "COMPLETENESS"
        },
        {
          rule_type = "UNIQUENESS"
          column    = "claim_id"
          threshold = 1.0
          dimension = "UNIQUENESS"
        }
      ]
    }
  ]

  # Data Profiling Scans
  profiling_scans = [
    {
      scan_id      = "claims-data-profile"
      lake_id      = "existing-insurance-lake"
      display_name = "Claims Data Profile"
      description  = "Statistical profiling of claims master table"
      data_source  = "//bigquery.googleapis.com/projects/${var.project_id}/datasets/acrwe_claims_analytics/tables/claims_master"
    }
  ]
}

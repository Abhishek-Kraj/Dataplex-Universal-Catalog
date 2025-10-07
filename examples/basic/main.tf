# Example: Using EXISTING GCS Buckets and BigQuery Datasets with Catalog
module "dataplex" {
  source = "../.."

  project_id = var.project_id
  region     = var.region
  location   = var.location

  enable_manage_lakes = true
  enable_metadata     = true
  enable_governance   = false

  # Metadata settings
  enable_catalog    = true
  enable_glossaries = true

  lakes = [
    {
      lake_id      = "existing-insurance-lake"
      display_name = "Existing Insurance Data Lake"
      zones = [
        # RAW Zone 1: Claims Data
        {
          zone_id          = "claims-raw-zone"
          type             = "RAW"
          existing_bucket  = "acrwe-claims-data-lake"
          create_storage   = false
        },
        # RAW Zone 2: Policy Data
        {
          zone_id          = "policy-raw-zone"
          type             = "RAW"
          existing_bucket  = "acrwe-policy-data-warehouse"
          create_storage   = false
        },
        # RAW Zone 3: Customer Analytics
        {
          zone_id          = "customer-raw-zone"
          type             = "RAW"
          existing_bucket  = "acrwe-customer-analytics"
          create_storage   = false
        },
        # CURATED Zone 1: Claims Analytics
        {
          zone_id          = "claims-analytics-zone"
          type             = "CURATED"
          existing_dataset = "acrwe_claims_analytics"
          create_storage   = false
        },
        # CURATED Zone 2: Policy Underwriting
        {
          zone_id          = "policy-underwriting-zone"
          type             = "CURATED"
          existing_dataset = "acrwe_policy_underwriting"
          create_storage   = false
        },
        # CURATED Zone 3: Customer Insights
        {
          zone_id          = "customer-insights-zone"
          type             = "CURATED"
          existing_dataset = "acrwe_customer_insights"
          create_storage   = false
        },
        # CURATED Zone 4: Analytics Warehouse
        {
          zone_id          = "analytics-warehouse-zone"
          type             = "CURATED"
          existing_dataset = "acrwe_analytics_warehouse"
          create_storage   = false
        },
        # CURATED Zone 5: ML Feature Store
        {
          zone_id          = "ml-feature-store-zone"
          type             = "CURATED"
          existing_dataset = "acrwe_ml_feature_store"
          create_storage   = false
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
}

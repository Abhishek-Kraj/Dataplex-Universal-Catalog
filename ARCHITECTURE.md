# Dataplex Universal Catalog Module - Architecture

## Design Philosophy: Focused & Composable

This module follows the **GCP Foundation** pattern of creating **focused, single-purpose modules** that can be composed together.

## What This Module DOES

This module creates **Dataplex-specific resources only**:

### ✅ Manage Lakes Module
- `google_dataplex_lake` - Data lakes
- `google_dataplex_zone` - Zones (RAW/CURATED)
- `google_dataplex_asset` - Assets (links to existing GCS/BQ)
- `google_dataplex_lake_iam_member` - Lake IAM bindings
- `google_dataplex_task` - Processing tasks (Spark/SQL/Notebooks)

### ✅ Metadata Module
- `google_dataplex_entry_group` - Entry groups
- `google_dataplex_entry_type` - Entry types
- `google_dataplex_aspect_type` - Aspect types
- `google_bigquery_table` - Glossary tables (specific to Dataplex)

### ✅ Governance Module
- `google_dataplex_datascan` - Data quality & profiling scans
- `google_bigquery_table` - Scan results tables (specific to Dataplex)

## What This Module DOES NOT Create

This module **does not create** general infrastructure resources. Instead, it **accepts them as inputs**:

### ❌ Service Accounts
- **Use existing**: Pass `service_account_email` parameter
- **Or use GCP Foundation module**: `modules/service_account`
- Example:
  ```hcl
  module "dataplex_sa" {
    source = "path/to/gcp-foundation/modules/service_account"
    # ...
  }

  module "dataplex" {
    source = "./dataplex-universal-catalog-tf-module"
    processing_service_account = module.dataplex_sa.email
  }
  ```

### ❌ GCS Buckets
- **Use existing**: Pass `artifacts_bucket` parameter for Spark artifacts
- **Or use GCP Foundation module**: `modules/terraform-google-cloud-storage`
- Rationale: Dataplex assets link to existing buckets, they don't manage bucket lifecycle

### ❌ BigQuery Datasets
- **Use existing**: Pass `results_dataset` parameter for processing results
- **Or use GCP Foundation module**: `modules/terraform-google-bigquery-7.0.0`
- Rationale: Dataplex assets link to existing datasets, they don't manage dataset lifecycle
- Exception: Glossary and scan results datasets ARE created (Dataplex-specific)

### ❌ Logging Sinks
- **Use existing**: Configure at organization/folder level
- **Or use GCP Foundation module**: `modules/terraform-google-cloud-operations`

### ❌ KMS Keys
- **Use existing**: Dataplex CMEK is organization-level
- Configure via: `gcloud dataplex encryption-config create`

## Dependency Management

### For Existing Resources (Recommended)

```hcl
# 1. Create infrastructure using GCP Foundation modules
module "service_accounts" {
  source = "../gcp-foundation/modules/service_account"
  # ...
}

module "storage_buckets" {
  source = "../gcp-foundation/modules/terraform-google-cloud-storage"
  # ...
}

module "bigquery_datasets" {
  source = "../gcp-foundation/modules/terraform-google-bigquery-7.0.0"
  # ...
}

# 2. Create Dataplex resources linking to existing infrastructure
module "dataplex" {
  source = "./dataplex-universal-catalog-tf-module"

  # Link to existing resources
  processing_service_account = module.service_accounts.email
  artifacts_bucket           = module.storage_buckets.name
  results_dataset            = module.bigquery_datasets.dataset_id

  # Define Dataplex-specific resources
  lakes = [
    {
      lake_id = "my-lake"
      zones = [
        {
          zone_id         = "raw-zone"
          type            = "RAW"
          existing_bucket = module.storage_buckets.name  # Link to existing
          create_storage  = false                         # Don't create new
        }
      ]
    }
  ]
}
```

### Benefits of This Approach

1. **Separation of Concerns**: Infrastructure vs. Dataplex catalog management
2. **Reusability**: Same buckets/datasets/SAs can be used by multiple Dataplex resources
3. **Standard Patterns**: Follows GCP Foundation module conventions
4. **Flexibility**: Users can use existing resources or create new ones
5. **Avoid Conflicts**: No "resource already exists" errors
6. **Better Lifecycle Management**: Resources have independent lifecycles

## Migration Path

### Current State (What We Have)
```hcl
# Module creates everything
module "dataplex" {
  enable_secure  = true  # Creates service accounts, audit config
  enable_process = true  # Creates bucket, dataset, service account
}
```

### Recommended State (Where We Should Go)
```hcl
# Module accepts references to existing resources
module "dataplex" {
  # Optional: only if running custom processing tasks
  processing_service_account = var.existing_sa_email      # Optional
  artifacts_bucket           = var.existing_bucket_name   # Optional
  results_dataset            = var.existing_dataset_id    # Optional

  # Focus: Dataplex resources only
  lakes          = var.lakes
  entry_groups   = var.entry_groups
  quality_scans  = var.quality_scans
}
```

## Implementation Plan

1. ✅ **Phase 1**: Add support for existing resources (DONE)
   - Added `existing_bucket`, `existing_dataset`, `create_storage` parameters
   - Assets can reference existing GCS/BQ resources

2. 🔄 **Phase 2**: Make infrastructure resources optional (IN PROGRESS)
   - Add `processing_service_account` parameter
   - Add `artifacts_bucket` parameter
   - Add `results_dataset` parameter
   - Remove `enable_secure` and `enable_process` resource creation

3. ⏭️ **Phase 3**: Remove infrastructure resource creation
   - Remove service account creation
   - Remove bucket creation
   - Remove non-Dataplex dataset creation
   - Keep only Dataplex-specific resources

4. ⏭️ **Phase 4**: Documentation
   - Update examples to show integration with GCP Foundation modules
   - Document resource dependencies clearly

## Summary

**This module should be a "Dataplex catalog management" module, not a "full data platform infrastructure" module.**

Following this principle makes it:
- More maintainable
- More composable
- More aligned with GCP Foundation patterns
- Less prone to conflicts
- Easier to use

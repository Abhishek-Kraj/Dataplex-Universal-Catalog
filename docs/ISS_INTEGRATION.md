# GCP Foundation Integration Guide

This guide shows how to integrate the Dataplex Universal Catalog module with your existing GCP Foundation codebase.

## Architecture Overview

```
gcp-foundation/
├── blueprints/level3/runtime_v2/
│   ├── builtin_gcs_v2.tf          # Creates GCS buckets
│   ├── builtin_bigquery.tf        # Creates BigQuery datasets
│   └── builtin_dataplex.tf        # ← NEW: Add Dataplex catalog
└── tfvars/
    └── {lbu}/{env}/projects/{project}.tfvars  # Your config file
```

## Step 1: Create Dataplex Module in Level 3

Create `/gcp-foundation/blueprints/level3/runtime_v2/builtin_dataplex.tf`:

```hcl
variable "dataplex_lakes" {
  type    = any
  default = {}
}

locals {
  dataplex_lakes = var.dataplex_lakes
}

module "project_dataplex" {
  for_each = local.dataplex_lakes

  # Reference your Dataplex module - adjust path as needed
  source = "git::https://github.com/Abhishek-Kraj/Dataplex-Universal-Catalog.git//?ref=master"

  project_id = local.project_id
  region     = local.availability_regions[lookup(each.value, "location", "az1")]
  location   = local.availability_regions[lookup(each.value, "location", "az1")]

  # Module toggles
  enable_manage_lakes = lookup(each.value, "enable_manage_lakes", true)
  enable_metadata     = lookup(each.value, "enable_metadata", true)
  enable_governance   = lookup(each.value, "enable_governance", true)

  # Feature flags
  enable_manage     = true
  enable_secure     = false  # Don't create SAs - use existing
  enable_process    = false  # Don't create Spark jobs
  enable_catalog    = lookup(each.value, "enable_catalog", true)
  enable_glossaries = lookup(each.value, "enable_glossaries", true)
  enable_quality    = lookup(each.value, "enable_quality", true)
  enable_profiling  = lookup(each.value, "enable_profiling", true)
  enable_monitoring = lookup(each.value, "enable_monitoring", false)

  # Lakes configuration
  lakes = lookup(each.value, "lakes", [])

  # Catalog configuration
  entry_groups  = lookup(each.value, "entry_groups", [])
  entry_types   = lookup(each.value, "entry_types", [])
  aspect_types  = lookup(each.value, "aspect_types", [])
  glossaries    = lookup(each.value, "glossaries", [])

  # Governance configuration
  quality_scans   = lookup(each.value, "quality_scans", [])
  profiling_scans = lookup(each.value, "profiling_scans", [])

  labels = {
    lbu    = local.lbu
    env    = local.env
    stage  = local.stage
    appref = local.appref
  }
}

output "dataplex_lakes" {
  value = {
    for key, lake in module.project_dataplex :
    key => {
      lakes        = lake.lakes
      entry_groups = lake.entry_groups
      quality_scans = lake.quality_scans
    }
  }
}
```

## Step 2: Add Configuration to Your tfvars File

Add to `/gcp-foundation/tfvars/{lbu}/{env}/projects/{project}.tfvars`:

```hcl
# ==============================================================================
# GCS Buckets (Existing Level 3 Module)
# ==============================================================================
gcs_buckets_v2 = {
  "claims-raw-data" : {
    storage_class = "STANDARD"
    location      = "az1"
    bucket_admins = {
      "1" : "serviceAccount:dataplex-sa@${PROJECT_ID}.iam.gserviceaccount.com"
    }
  }

  "policy-data-warehouse" : {
    storage_class = "NEARLINE"
    location      = "az1"
  }
}

# ==============================================================================
# BigQuery Datasets (Existing Level 3 Module)
# ==============================================================================
bigquery_datasets = {
  "claims_analytics" : {
    location = "az1"
    tables = [
      {
        table_id = "claims_master"
        schema   = "./schemas/claims_master.json"
        clustering = ["claim_id"]
      }
    ]
  }

  "policy_underwriting" : {
    location = "az1"
  }
}

# ==============================================================================
# Dataplex Universal Catalog (NEW)
# ==============================================================================
dataplex_lakes = {
  "insurance-data-catalog" : {
    location = "az1"

    enable_catalog    = true
    enable_glossaries = true
    enable_quality    = true
    enable_profiling  = true

    lakes = [
      {
        lake_id      = "insurance-lake"
        display_name = "Insurance Data Lake"

        zones = [
          # RAW zones - link to existing GCS buckets
          {
            zone_id          = "claims-raw"
            type             = "RAW"
            display_name     = "Claims Raw Data"
            existing_bucket  = "${LBU}-${ENV}-${STAGE}-${APPREF}-${AZ}-claims-raw-data"
          },
          {
            zone_id          = "policy-raw"
            type             = "RAW"
            display_name     = "Policy Data Warehouse"
            existing_bucket  = "${LBU}-${ENV}-${STAGE}-${APPREF}-${AZ}-policy-data-warehouse"
          },

          # CURATED zones - link to existing BigQuery datasets
          {
            zone_id          = "claims-analytics"
            type             = "CURATED"
            display_name     = "Claims Analytics"
            existing_dataset = "claims_analytics"
          },
          {
            zone_id          = "policy-underwriting"
            type             = "CURATED"
            display_name     = "Policy Underwriting"
            existing_dataset = "policy_underwriting"
          }
        ]
      }
    ]

    # Entry groups for metadata organization
    entry_groups = [
      {
        entry_group_id = "insurance-claims-data"
        display_name   = "Insurance Claims Data"
        description    = "Entry group for claims-related data assets"
      },
      {
        entry_group_id = "insurance-policy-data"
        display_name   = "Insurance Policy Data"
        description    = "Entry group for policy-related data assets"
      }
    ]

    # Business glossary terms
    glossaries = [
      {
        glossary_id  = "insurance-business-terms"
        display_name = "Insurance Business Glossary"
        terms = [
          {
            term_id     = "claim"
            display_name = "Claim"
            description = "A formal request by a policyholder for coverage or compensation"
          },
          {
            term_id     = "policy"
            display_name = "Policy"
            description = "A contract between insurer and policyholder"
          }
        ]
      }
    ]

    # Data quality scans
    quality_scans = [
      {
        scan_id     = "claims-data-quality"
        lake_id     = "insurance-lake"
        display_name = "Claims Data Quality Check"
        data_source = "//bigquery.googleapis.com/projects/${PROJECT_ID}/datasets/claims_analytics/tables/claims_master"
        rules = [
          { rule_type = "NON_NULL", column = "claim_id", threshold = 1.0, dimension = "COMPLETENESS" },
          { rule_type = "UNIQUENESS", column = "claim_id", threshold = 1.0, dimension = "UNIQUENESS" }
        ]
      }
    ]

    # Data profiling scans
    profiling_scans = [
      {
        scan_id     = "claims-data-profile"
        lake_id     = "insurance-lake"
        display_name = "Claims Data Profiling"
        data_source = "//bigquery.googleapis.com/projects/${PROJECT_ID}/datasets/claims_analytics/tables/claims_master"
      }
    ]
  }
}
```

## Step 3: Deploy Following GCP Foundation Workflow

### Standard Deployment

```bash
# Navigate to your blueprint
cd gcp-foundation/blueprints/level3/runtime_v2

# Initialize Terraform
terraform init

# Plan with your tfvars
terraform plan -var-file="../../../tfvars/{lbu}/{env}/projects/{project}.tfvars"

# Apply
terraform apply -var-file="../../../tfvars/{lbu}/{env}/projects/{project}.tfvars"
```

### Using GCP Foundation CI/CD

If you use Jenkins/GitHub Actions, the pipeline will automatically:
1. Create GCS buckets via `builtin_gcs_v2.tf`
2. Create BigQuery datasets via `builtin_bigquery.tf`
3. Create Dataplex catalog via `builtin_dataplex.tf` (referencing existing resources)

## Key Integration Points

### 1. Bucket Naming Convention

GCP Foundation creates buckets with this pattern:
```
{LBU}-{ENV}-{STAGE}-{APPREF}-{AZ}-{bucket-name}
```

Example: `pru-prod-runtime-claims-az1-claims-raw-data`

In Dataplex config, use the **full bucket name**:
```hcl
existing_bucket = "${LBU}-${ENV}-${STAGE}-${APPREF}-${AZ}-claims-raw-data"
```

### 2. Dataset Naming Convention

BigQuery datasets use the key from `bigquery_datasets`:
```hcl
bigquery_datasets = {
  "claims_analytics" : { ... }  # Dataset ID: claims_analytics
}
```

In Dataplex config, reference directly:
```hcl
existing_dataset = "claims_analytics"
```

### 3. Service Accounts

**Option A - Use existing SA from GCP Foundation:**
```hcl
# In builtin_dataplex.tf, reference existing SA
service_account_email = module.project_service_accounts["dataplex-sa"].email
```

**Option B - Let Dataplex module handle (recommended):**
```hcl
enable_secure = false  # Don't create new SAs
```

### 4. Labels Consistency

Apply same labels as GCP Foundation:
```hcl
labels = {
  lbu    = local.lbu
  env    = local.env
  stage  = local.stage
  appref = local.appref
}
```

## Benefits of This Integration

✅ **Unified Management**: All infrastructure in one codebase
✅ **Consistent Naming**: Follows GCP Foundation patterns
✅ **No Duplication**: References existing buckets/datasets
✅ **Automated Deployment**: Uses existing CI/CD pipelines
✅ **Standard Labels**: Consistent tagging across all resources
✅ **IAM Integration**: Works with existing service accounts

## Example Output

After deployment:
```
Outputs:

gcs_buckets_v2 = {
  "claims-raw-data" = {
    name = "pru-prod-runtime-claims-az1-claims-raw-data"
    url  = "gs://pru-prod-runtime-claims-az1-claims-raw-data"
  }
}

bigquery_datasets = {
  "claims_analytics" = {
    dataset_id = "claims_analytics"
    location   = "asia-southeast1"
  }
}

dataplex_lakes = {
  "insurance-data-catalog" = {
    lakes = {
      "insurance-lake" = "projects/.../lakes/insurance-lake"
    }
    entry_groups = {
      "insurance-claims-data" = "projects/.../entryGroups/insurance-claims-data"
    }
    quality_scans = {
      "claims-data-quality" = "projects/.../dataScans/claims-data-quality"
    }
  }
}
```

## Migration Path for Existing Deployments

If you already have GCS/BigQuery deployed via GCP Foundation:

1. **Add `builtin_dataplex.tf`** to your blueprint
2. **Update tfvars** with `dataplex_lakes` configuration
3. **Reference existing resources** using `existing_bucket`/`existing_dataset`
4. **Run terraform plan** - should only create Dataplex resources
5. **Apply** - no changes to existing buckets/datasets

## Troubleshooting

### Issue: Bucket names don't match
**Solution**: Check the actual bucket name in GCS console or use:
```bash
gsutil ls gs://{LBU}-{ENV}-*
```

### Issue: Dataset not found
**Solution**: Verify dataset exists:
```bash
bq ls --project_id={PROJECT_ID}
```

### Issue: Permission denied
**Solution**: Add Dataplex permissions to service account:
```bash
gcloud projects add-iam-policy-binding {PROJECT_ID} \
  --member="serviceAccount:terraform-sa@{PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/dataplex.admin"
```

## Next Steps

1. Review [ARCHITECTURE.md](../ARCHITECTURE.md) for design principles
2. Check [examples/basic/README.md](../examples/basic/README.md) for detailed configuration
3. Test in sandbox environment first (`prusandbx`)
4. Roll out to production environments

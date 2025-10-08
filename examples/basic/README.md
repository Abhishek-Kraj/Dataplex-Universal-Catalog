# Basic Example - Using Existing Infrastructure

This example demonstrates how to use the Dataplex module with **existing infrastructure** (GCS buckets, BigQuery datasets) instead of creating new resources.

## 🎯 Recommended Approach

This example follows **GCP Foundation patterns** where:
- ✅ Infrastructure (buckets, datasets, service accounts) exists separately
- ✅ Dataplex module focuses on catalog management (lakes, zones, assets, metadata)
- ✅ No resource conflicts or duplication
- ✅ Clean separation of concerns

## ✅ What's Included (All Terraform-Supported)

This example deploys:

### **Infrastructure (Using Existing Resources)**
- 1 Data Lake (`existing-insurance-lake`)
- 8 Zones:
  - **RAW Zones** (linked to existing GCS buckets):
    - `claims-raw-zone` → `acrwe-claims-data-lake`
    - `policy-raw-zone` → `acrwe-policy-data-warehouse`
    - `customer-raw-zone` → `acrwe-customer-analytics`
  - **CURATED Zones** (linked to existing BigQuery datasets):
    - `claims-analytics-zone` → `acrwe_claims_analytics`
    - `policy-underwriting-zone` → `acrwe_policy_underwriting`
    - `customer-insights-zone` → `acrwe_customer_insights`
    - `analytics-warehouse-zone` → `acrwe_analytics_warehouse`
    - `ml-feature-store-zone` → `acrwe_ml_feature_store`

### **Catalog & Metadata**
- 3 Entry Groups (`insurance-claims-data`, `insurance-policy-data`, `customer-analytics-data`)
- 2 Entry Types (`data_asset`, `table`)
- 4 Aspect Types (`data_quality`, `business_metadata`, `lineage`, `glossary_term`)
- 1 Business Glossary with 4 insurance terms

### **Data Quality & Governance**
- 1 Quality scan with 2 validation rules (NON_NULL, UNIQUENESS)
- 1 Profiling scan for statistical analysis
- BigQuery datasets for scan results storage

## 🚫 What's NOT Included

- ❌ **New infrastructure creation** (buckets, datasets, service accounts) - use existing resources instead
- ❌ **Security resources** (`enable_secure = false`) - manage separately via GCP Foundation modules
- ❌ **Processing tasks** (`enable_process = false`) - Spark/Dataflow jobs managed separately
- ❌ **Monitoring** (`enable_monitoring = false`) - optional, can be enabled if needed
- ❌ Search interface (use Console)
- ❌ Column-level aspects (use SDK/API)
- ❌ Data lineage (auto-generated)

## 📋 Prerequisites

Before deploying, ensure you have:

1. **Existing GCS Buckets** (for RAW zones):
   - `acrwe-claims-data-lake`
   - `acrwe-policy-data-warehouse`
   - `acrwe-customer-analytics`

2. **Existing BigQuery Datasets** (for CURATED zones):
   - `acrwe_claims_analytics`
   - `acrwe_policy_underwriting`
   - `acrwe_customer_insights`
   - `acrwe_analytics_warehouse`
   - `acrwe_ml_feature_store`

3. **Existing BigQuery Table** (for data scans):
   - `acrwe_claims_analytics.claims_master`

4. **IAM Permissions**:
   - `roles/dataplex.admin` - For creating lakes, zones, assets
   - `roles/datacatalog.admin` - For entry groups and aspect types
   - `roles/bigquery.jobUser` - For data scans

## 📋 Configuration

**Project**: `prusandbx-nprd-uat-iywjo9`
**Region**: `asia-southeast1` (Singapore)

## 🚀 Deploy

```bash
# 1. Navigate to this directory
cd examples/basic

# 2. Initialize Terraform
terraform init

# 3. Review the plan
terraform plan

# 4. Deploy
terraform apply

# 5. View outputs
terraform output
```

## 📊 Expected Resources

After deployment, you'll have:

| Resource Type | Count | Examples |
|--------------|-------|----------|
| **Lakes** | 1 | existing-insurance-lake |
| **Zones** | 8 | claims-raw-zone, policy-raw-zone, claims-analytics-zone, etc. |
| **Assets** | 8 | GCS bucket assets (3), BigQuery dataset assets (5) |
| **Entry Groups** | 3 | insurance-claims-data, insurance-policy-data, customer-analytics-data |
| **Entry Types** | 2 | data_asset, table |
| **Aspect Types** | 4 | data_quality, business_metadata, lineage, glossary_term |
| **Glossaries** | 1 | insurance-business-terms (4 terms) |
| **Quality Scans** | 1 | claims-data-quality |
| **Profiling Scans** | 1 | claims-data-profile |
| **BigQuery Datasets** | 3 | Glossary dataset, quality results, profiling results |
| **BigQuery Tables/Views** | 8 | Glossary tables, scan result tables |

**Total**: ~51 resources (25 manage-lakes + 15 metadata + 11 governance)

### Key Features:
- ✅ **No new infrastructure created** - all zones link to existing buckets/datasets
- ✅ **Catalog-focused** - entry groups, types, aspect types for metadata management
- ✅ **Data quality enabled** - automated scans with validation rules
- ✅ **Business glossary** - standardized insurance terminology

## 🔍 Verify Deployment

```bash
# Check lakes
gcloud dataplex lakes list \
  --location=asia-southeast1 \
  --project=prusandbx-nprd-uat-iywjo9

# Check taxonomies
gcloud data-catalog taxonomies list \
  --location=asia-southeast1 \
  --project=prusandbx-nprd-uat-iywjo9

# Check data scans
gcloud dataplex datascans list \
  --location=asia-southeast1 \
  --project=prusandbx-nprd-uat-iywjo9

# Check entry groups
gcloud dataplex entry-groups list \
  --location=asia-southeast1 \
  --project=prusandbx-nprd-uat-iywjo9
```

## 🧹 Cleanup

```bash
terraform destroy
```

## 📝 Key Configuration Patterns

### Using Existing Resources

Set `create_storage = false` and provide existing resource names:

```hcl
zones = [
  # RAW zone with existing GCS bucket
  {
    zone_id          = "claims-raw-zone"
    type             = "RAW"
    existing_bucket  = "acrwe-claims-data-lake"  # Existing bucket name
    create_storage   = false                      # Don't create new bucket
  },
  # CURATED zone with existing BigQuery dataset
  {
    zone_id          = "claims-analytics-zone"
    type             = "CURATED"
    existing_dataset = "acrwe_claims_analytics"   # Existing dataset ID
    create_storage   = false                      # Don't create new dataset
  }
]
```

### Creating New Resources with Custom Names

Set `create_storage = true` and optionally provide custom names:

```hcl
zones = [
  # RAW zone with custom bucket name
  {
    zone_id        = "raw-zone"
    type           = "RAW"
    create_storage = true
    bucket_name    = "my-company-raw-data-bucket"  # Custom name (optional)
  },
  # RAW zone with auto-generated name
  {
    zone_id        = "bronze-zone"
    type           = "RAW"
    create_storage = true
    # bucket_name not specified, will auto-generate: "project-id-lake-id-bronze-zone"
  },
  # CURATED zone with custom dataset ID
  {
    zone_id        = "analytics-zone"
    type           = "CURATED"
    create_storage = true
    dataset_id     = "my_analytics_dataset"        # Custom ID (optional)
  },
  # CURATED zone with auto-generated ID
  {
    zone_id        = "silver-zone"
    type           = "CURATED"
    create_storage = true
    # dataset_id not specified, will auto-generate: "lake_id_silver_zone"
  }
]
```

### Data Quality Scans

Reference existing BigQuery tables for quality checks:

```hcl
quality_scans = [
  {
    scan_id     = "claims-data-quality"
    data_source = "//bigquery.googleapis.com/projects/${var.project_id}/datasets/acrwe_claims_analytics/tables/claims_master"
    rules = [
      { rule_type = "NON_NULL", column = "claim_id", threshold = 1.0, dimension = "COMPLETENESS" },
      { rule_type = "UNIQUENESS", column = "claim_id", threshold = 1.0, dimension = "UNIQUENESS" }
    ]
  }
]
```

## 📝 Notes

- This example uses **100% Terraform-supported features**
- **No new infrastructure created** - focuses on Dataplex catalog resources only
- Follows **GCP Foundation patterns** - infrastructure managed separately
- Configuration is version-controlled and reproducible
- All zones link to pre-existing GCS buckets and BigQuery datasets

For features not supported in Terraform, see [../../TERRAFORM_SUPPORT.md](../../TERRAFORM_SUPPORT.md).

## 💡 Next Steps

1. Review created resources in GCP Console
2. Test data quality scan functionality
3. Explore entry groups and aspect types
4. View glossary terms in BigQuery
5. Customize for your own data sources

## 🎯 Production Readiness

This example follows production best practices:
- ✅ **Separation of concerns** - Dataplex catalog separate from infrastructure
- ✅ **Reusable infrastructure** - existing buckets/datasets remain intact
- ✅ **Data quality automation** - automated scans with validation rules
- ✅ **Metadata management** - entry groups, types, and business glossaries
- ✅ **Infrastructure as code** - 100% Terraform, no manual steps

## 🔗 Integration with GCP Foundation

This module integrates with GCP Foundation modules:

- **Service Accounts**: Use [terraform-google-service-accounts](https://github.com/terraform-google-modules/terraform-google-service-accounts)
- **GCS Buckets**: Use [terraform-google-cloud-storage](https://github.com/terraform-google-modules/terraform-google-cloud-storage)
- **BigQuery**: Use [terraform-google-bigquery](https://github.com/terraform-google-modules/terraform-google-bigquery)

See [../../ARCHITECTURE.md](../../ARCHITECTURE.md) for integration patterns.

---

**Coverage**: This example represents the **65% of Dataplex features** that are fully supported in Terraform, focusing on catalog and governance capabilities.

# Quick Start - Deploy Dataplex Module

## Prerequisites
- Terraform installed (>= 1.3)
- GCP authentication configured
- Project: `prusandbx-nprd-uat-iywjo9`

## Deployment Steps

### 1. Navigate to Basic Example
```bash
cd examples/basic
```

### 2. Initialize Terraform
```bash
terraform init
```

### 3. Review the Plan
```bash
terraform plan
```

### 4. Apply the Configuration
```bash
terraform apply
```
Type `yes` when prompted to confirm.

### 5. Verify Resources
```bash
# Check outputs
terraform output

# List created lakes
gcloud dataplex lakes list --location=us-central1 --project=prusandbx-nprd-uat-iywjo9

# List taxonomies
gcloud data-catalog taxonomies list --location=us-central1 --project=prusandbx-nprd-uat-iywjo9
```

## Cleanup

To destroy all resources:
```bash
terraform destroy
```
Type `yes` when prompted.

## What Gets Deployed (Basic Example)

### Discover Module
- Data Catalog Taxonomy with policy tags
- 3 Metadata templates (asset, table, column)
- Search infrastructure (BigQuery datasets)

### Manage Metadata Module
- 1 Entry group: `customer-data`
- 3 Entry types and 3 Aspect types
- Business glossary infrastructure

### Manage Lakes Module
- 1 Lake: `analytics-lake`
- 2 Zones: `raw-zone` (RAW), `curated-zone` (CURATED)
- GCS bucket for raw zone
- BigQuery dataset for curated zone
- 2 Assets linked to the zones

## Troubleshooting

**Error: API not enabled**
```bash
gcloud services enable dataplex.googleapis.com --project=prusandbx-nprd-uat-iywjo9
gcloud services enable datacatalog.googleapis.com --project=prusandbx-nprd-uat-iywjo9
```

**Error: Permission denied**
Ensure your service account has required roles:
- roles/dataplex.admin
- roles/datacatalog.admin
- roles/bigquery.admin
- roles/storage.admin

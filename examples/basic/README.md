# Basic Example - Dataplex Universal Catalog

This example deploys a minimal Dataplex setup with:
- 1 Lake with 2 zones (RAW and CURATED)
- Data Catalog taxonomy with policy tags
- Metadata templates
- Entry groups for cataloging

## Configuration

Project: `prusandbx-nprd-uat-iywjo9`
Region: `asia-southeast1` (Singapore)

## Deploy

```bash
# 1. Initialize
terraform init

# 2. Plan
terraform plan

# 3. Apply
terraform apply

# 4. View outputs
terraform output
```

## Destroy

```bash
terraform destroy
```

## Resources Created

- **Lake**: analytics-lake
- **Zones**: raw-zone, curated-zone
- **Entry Group**: customer-data
- **Taxonomy**: with 3 policy tags (Confidential, Public, Internal)
- **Templates**: 3 metadata templates
- **Storage**: GCS bucket + BigQuery datasets

# Dataplex Manage Metadata Module

This module manages Dataplex Universal Catalog metadata including entry groups, entry types, aspect types, and business glossaries.

## Features

- ✅ **Entry Groups**: Organize catalog entries
- ✅ **Entry Types**: Define custom entry schemas
- ✅ **Aspect Types**: Create metadata templates
- ✅ **Business Glossaries**: Manage business terminology (stored in BigQuery)

## Resources Created

- `google_dataplex_entry_group`
- `google_dataplex_entry_type`
- `google_dataplex_entry`
- `google_dataplex_aspect_type`
- `google_bigquery_dataset` (for glossaries)
- `google_bigquery_table` (glossary storage)

## Usage

```hcl
module "dataplex_metadata" {
  source = "git::https://github.com/your-org/dataplex-modules.git//modules/manage-metadata"

  project_id = "my-gcp-project"
  region     = "us-central1"
  location   = "us-central1"

  # Enable/disable sub-features
  enable_catalog    = true
  enable_glossaries = true

  # Define entry groups
  entry_groups = [
    {
      entry_group_id = "customer-data"
      display_name   = "Customer Data Assets"
      description    = "Entry group for customer-related data assets"
    },
    {
      entry_group_id = "product-data"
      display_name   = "Product Catalog"
      description    = "Entry group for product and inventory data"
    }
  ]

  # Define business glossaries
  glossaries = [
    {
      glossary_id  = "business-terms"
      display_name = "Business Glossary"
      description  = "Enterprise business terminology"
      terms = [
        {
          term_id      = "customer"
          display_name = "Customer"
          description  = "Individual or organization purchasing products/services"
        },
        {
          term_id      = "revenue"
          display_name = "Revenue"
          description  = "Total income generated from business operations"
        },
        {
          term_id      = "churn"
          display_name = "Customer Churn"
          description  = "Rate at which customers stop doing business"
        }
      ]
    }
  ]

  labels = {
    managed_by = "terraform"
    purpose    = "metadata-management"
  }
}
```

## Entry Groups vs Entry Types vs Aspect Types

| Resource | Purpose | Example |
|----------|---------|---------|
| **Entry Group** | Container for organizing entries | "Customer Data", "Financial Data" |
| **Entry Type** | Schema definition for entries | "Table", "Dashboard", "ML Model" |
| **Aspect Type** | Metadata template attached to entries | "Data Quality", "Business Context", "Lineage" |

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_id | GCP project ID | string | - | yes |
| region | GCP region | string | - | yes |
| location | GCP location | string | - | yes |
| enable_catalog | Enable catalog features | bool | true | no |
| enable_glossaries | Enable glossaries | bool | true | no |
| entry_groups | Entry group configurations | list(object) | [] | no |
| glossaries | Glossary configurations | list(object) | [] | no |
| labels | Global labels | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| entry_groups | Created entry groups |
| entry_types | Created entry types |
| aspect_types | Created aspect types |
| glossary_datasets | BigQuery datasets for glossaries |

## Requirements

- Terraform >= 1.3
- Google Provider >= 5.0

## APIs Required

- `dataplex.googleapis.com`
- `datacatalog.googleapis.com`
- `bigquery.googleapis.com`

## Use Cases

### 1. Data Catalog Organization
Create entry groups to organize your data assets logically:
```hcl
entry_groups = [
  { entry_group_id = "finance", display_name = "Financial Data" },
  { entry_group_id = "customer", display_name = "Customer Data" },
  { entry_group_id = "product", display_name = "Product Catalog" }
]
```

### 2. Business Glossary
Define business terms for consistent understanding:
```hcl
glossaries = [{
  glossary_id = "sales-terms"
  terms = [
    { term_id = "arr", display_name = "Annual Recurring Revenue" },
    { term_id = "ltv", display_name = "Customer Lifetime Value" }
  ]
}]
```

### 3. Custom Metadata
Create aspect types for custom metadata fields:
- Data Quality metrics
- Business ownership
- Data lineage
- Compliance tags

## Reference

- [Official Dataplex Terraform Documentation](https://cloud.google.com/dataplex/docs/terraform)
- [Dataplex Universal Catalog](https://cloud.google.com/dataplex/docs/catalog-overview)

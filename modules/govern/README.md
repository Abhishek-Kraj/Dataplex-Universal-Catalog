# Dataplex Govern Module

This module manages Dataplex data quality and profiling scans, with integrated monitoring and alerting capabilities.

## Features

- ✅ **Data Quality Scans**: Automated data quality validation with 5 rule types
- ✅ **Data Profiling**: Statistical profiling of data characteristics
- ✅ **Monitoring**: Cloud Monitoring dashboards, alerts, and SLOs
- ✅ **BigQuery Integration**: Store scan results in BigQuery for analysis

## Resources Created

- `google_dataplex_datascan` (quality and profiling)
- `google_bigquery_dataset` (for results storage)
- `google_bigquery_table` (results, metrics, views)
- `google_monitoring_dashboard`
- `google_monitoring_alert_policy`
- `google_monitoring_slo`
- `google_logging_metric`

## Usage

```hcl
module "dataplex_govern" {
  source = "git::https://github.com/your-org/dataplex-modules.git//modules/govern"

  project_id = "my-gcp-project"
  region     = "us-central1"
  location   = "us-central1"

  # Enable/disable sub-features
  enable_profiling  = true
  enable_quality    = true
  enable_monitoring = true

  # Define data quality scans
  quality_scans = [
    {
      scan_id      = "customer-quality"
      lake_id      = "analytics-lake"
      display_name = "Customer Data Quality"
      description  = "Validate customer data quality"
      data_source  = "//bigquery.googleapis.com/projects/my-project/datasets/customers/tables/customer_master"

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
        }
      ]
    }
  ]

  # Define profiling scans
  profiling_scans = [
    {
      scan_id      = "customer-profile"
      lake_id      = "analytics-lake"
      display_name = "Customer Data Profile"
      description  = "Statistical profiling of customer data"
      data_source  = "//bigquery.googleapis.com/projects/my-project/datasets/customers/tables/customer_master"
    }
  ]

  labels = {
    managed_by = "terraform"
    purpose    = "data-governance"
  }
}
```

## Data Quality Rule Types

| Rule Type | Description | Example Use Case |
|-----------|-------------|------------------|
| NON_NULL | Check for null values | Validate required fields |
| UNIQUENESS | Check for unique values | Validate primary keys |
| REGEX | Pattern matching | Validate email, phone formats |
| RANGE | Value range validation | Check numeric bounds |
| SET_MEMBERSHIP | Value in allowed set | Validate status codes |

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_id | GCP project ID | string | - | yes |
| region | GCP region | string | - | yes |
| location | GCP location | string | - | yes |
| enable_profiling | Enable data profiling | bool | true | no |
| enable_quality | Enable quality scans | bool | true | no |
| enable_monitoring | Enable monitoring/alerts | bool | true | no |
| quality_scans | Quality scan configurations | list(object) | [] | no |
| profiling_scans | Profiling scan configurations | list(object) | [] | no |
| labels | Global labels | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| quality_scans | Created data quality scans |
| profiling_scans | Created profiling scans |
| quality_datasets | BigQuery datasets for results |
| monitoring_dashboards | Monitoring dashboard URLs |
| alert_policies | Alert policy IDs |

## Requirements

- Terraform >= 1.3
- Google Provider >= 5.0

## APIs Required

- `dataplex.googleapis.com`
- `bigquery.googleapis.com`
- `monitoring.googleapis.com`
- `logging.googleapis.com`

## Reference

- [Official Dataplex Terraform Documentation](https://cloud.google.com/dataplex/docs/terraform)
- [Dataplex Data Quality](https://cloud.google.com/dataplex/docs/check-data-quality)

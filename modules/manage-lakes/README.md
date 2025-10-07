# Dataplex Manage Lakes Module

This module manages Dataplex lakes, zones, assets, and tasks. It provides comprehensive lake management, security (IAM), and data processing capabilities.

## Features

- ✅ **Lakes**: Create and manage Dataplex lakes
- ✅ **Zones**: Configure RAW and CURATED zones
- ✅ **Assets**: Attach GCS buckets and BigQuery datasets
- ✅ **IAM Bindings**: Configure lake-level permissions
- ✅ **Tasks**: Deploy Spark jobs, notebooks, and data processing pipelines

## Resources Created

- `google_dataplex_lake`
- `google_dataplex_zone`
- `google_dataplex_asset`
- `google_dataplex_task`
- `google_dataplex_lake_iam_member`
- `google_dataplex_lake_iam_binding`
- `google_storage_bucket` (for artifacts)
- `google_service_account` (for task execution)

## Usage

```hcl
module "dataplex_lakes" {
  source = "git::https://github.com/your-org/dataplex-modules.git//modules/manage-lakes"

  project_id = "my-gcp-project"
  region     = "us-central1"
  location   = "us-central1"

  # Enable/disable sub-features
  enable_manage  = true
  enable_secure  = true
  enable_process = true

  # Define lakes and zones
  lakes = [
    {
      lake_id      = "analytics-lake"
      display_name = "Analytics Data Lake"
      description  = "Central lake for analytics workloads"
      labels = {
        environment = "production"
      }
      zones = [
        {
          zone_id       = "raw-zone"
          type          = "RAW"
          display_name  = "Raw Data Zone"
          description   = "Landing zone for raw data"
          location_type = "SINGLE_REGION"
        },
        {
          zone_id       = "curated-zone"
          type          = "CURATED"
          display_name  = "Curated Data Zone"
          description   = "Processed and validated data"
          location_type = "SINGLE_REGION"
        }
      ]
    }
  ]

  # Configure IAM bindings
  iam_bindings = [
    {
      lake_id = "analytics-lake"
      role    = "roles/dataplex.viewer"
      members = [
        "group:data-analysts@example.com"
      ]
    }
  ]

  # Define Spark jobs
  spark_jobs = [
    {
      job_id       = "etl-pipeline"
      lake_id      = "analytics-lake"
      display_name = "ETL Pipeline"
      description  = "Transform raw to curated data"
      main_class   = "com.example.ETLPipeline"
      main_jar_uri = "gs://my-bucket/jars/etl.jar"
      args         = ["--input=raw", "--output=curated"]
    }
  ]

  labels = {
    managed_by = "terraform"
    team       = "data-platform"
  }
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_id | GCP project ID | string | - | yes |
| region | GCP region | string | - | yes |
| location | GCP location | string | - | yes |
| enable_manage | Enable lake management | bool | true | no |
| enable_secure | Enable IAM security features | bool | true | no |
| enable_process | Enable data processing tasks | bool | true | no |
| lakes | List of lakes with zones | list(object) | [] | no |
| iam_bindings | IAM role bindings | list(object) | [] | no |
| spark_jobs | Spark job configurations | list(object) | [] | no |
| labels | Global labels | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| lakes | Created Dataplex lakes |
| zones | Created Dataplex zones |
| assets | Created Dataplex assets |
| tasks | Created Dataplex tasks |
| service_accounts | Service accounts for task execution |

## Requirements

- Terraform >= 1.3
- Google Provider >= 5.0

## APIs Required

- `dataplex.googleapis.com`
- `storage.googleapis.com`
- `iam.googleapis.com`

## Reference

- [Official Dataplex Terraform Documentation](https://cloud.google.com/dataplex/docs/terraform)

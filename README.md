# Dataplex Universal Catalog - Terraform Modules

**Production-ready, variable-driven Terraform modules for Google Cloud Dataplex Universal Catalog.**

This repository provides standalone, self-contained modules for managing Dataplex resources. Each module can be used independently by anyone in your organization.

## 🏗️ Module Structure

```
dataplex-universal-catalog-tf-module/
├── modules/
│   ├── manage-lakes/          # Lakes, zones, assets, tasks, IAM
│   ├── manage-metadata/       # Entry groups, entry types, aspect types, glossaries
│   └── govern/                # Data quality, profiling, monitoring
└── examples/
    ├── basic/                 # Simple setup
    └── complete/              # Production-ready configuration
```

## ✨ Features

### 🏞️ [manage-lakes](modules/manage-lakes/) - Lake Management
- ✅ Dataplex lakes and zones (RAW/CURATED)
- ✅ Assets (GCS buckets, BigQuery datasets)
- ✅ IAM bindings and security
- ✅ Spark jobs and data processing tasks
- ✅ Service accounts with proper permissions

**Resources:** `google_dataplex_lake`, `google_dataplex_zone`, `google_dataplex_asset`, `google_dataplex_task`

### 📚 [manage-metadata](modules/manage-metadata/) - Metadata Management
- ✅ Entry groups for organizing data assets
- ✅ Entry types for custom schemas
- ✅ Aspect types for metadata templates
- ✅ Business glossaries (stored in BigQuery)

**Resources:** `google_dataplex_entry_group`, `google_dataplex_entry_type`, `google_dataplex_aspect_type`, `google_dataplex_entry`

### 🛡️ [govern](modules/govern/) - Data Governance
- ✅ Data quality scans (5 rule types: NON_NULL, UNIQUENESS, REGEX, RANGE, SET_MEMBERSHIP)
- ✅ Data profiling scans with statistics
- ✅ Cloud Monitoring dashboards, alerts, and SLOs
- ✅ BigQuery datasets for results storage

**Resources:** `google_dataplex_datascan`, `google_monitoring_dashboard`, `google_monitoring_alert_policy`

## 🚀 Quick Start

### Using Individual Modules

Each module is **standalone** and can be used independently:

```hcl
# Example 1: Just create lakes
module "lakes" {
  source = "git::https://github.com/your-org/repo.git//modules/manage-lakes"

  project_id = "my-project"
  region     = "us-central1"
  location   = "us-central1"

  lakes = [
    {
      lake_id = "analytics-lake"
      zones = [
        { zone_id = "raw-zone", type = "RAW" },
        { zone_id = "curated-zone", type = "CURATED" }
      ]
    }
  ]
}

# Example 2: Add data quality
module "quality" {
  source = "git::https://github.com/your-org/repo.git//modules/govern"

  project_id = "my-project"
  region     = "us-central1"
  location   = "us-central1"

  quality_scans = [
    {
      scan_id     = "customer-quality"
      lake_id     = "analytics-lake"
      data_source = "//bigquery.googleapis.com/projects/my-project/datasets/customers"
      rules = [
        { rule_type = "NON_NULL", column = "customer_id", threshold = 1.0 }
      ]
    }
  ]
}

# Example 3: Add metadata management
module "metadata" {
  source = "git::https://github.com/your-org/repo.git//modules/manage-metadata"

  project_id = "my-project"
  region     = "us-central1"
  location   = "us-central1"

  entry_groups = [
    { entry_group_id = "customer-data", display_name = "Customer Data" }
  ]
}
```

## 📖 Module Documentation

Each module has comprehensive documentation:

- [manage-lakes README](modules/manage-lakes/README.md)
- [manage-metadata README](modules/manage-metadata/README.md)
- [govern README](modules/govern/README.md)

## 📋 Examples

### Basic Example
See [examples/basic/](examples/basic/) for a simple, minimal configuration.

```bash
cd examples/basic
terraform init
terraform plan
terraform apply
```

### Complete Example
See [examples/complete/](examples/complete/) for a production-ready configuration with all features.

```bash
cd examples/complete
terraform init
terraform plan
terraform apply
```

## 🔧 Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3 |
| google | >= 5.0, < 7.0 |

## 🌐 Required GCP APIs

Enable these APIs in your GCP project:

```bash
gcloud services enable dataplex.googleapis.com
gcloud services enable datacatalog.googleapis.com
gcloud services enable bigquery.googleapis.com
gcloud services enable storage.googleapis.com
gcloud services enable monitoring.googleapis.com
gcloud services enable logging.googleapis.com
```

## 🎯 Why These Modules?

### ✅ Most Comprehensive Dataplex Terraform Modules
- **Only** public modules with Entry Groups & Entry Types
- **Only** modules with Dataplex Tasks (Spark jobs, notebooks)
- **Only** modules with full monitoring/alerting
- Complete data governance (quality + profiling)
- Production-ready with encryption, IAM, and monitoring

### ✅ Based on Official Google Documentation
- 100% aligned with [official Dataplex Terraform docs](https://cloud.google.com/dataplex/docs/terraform)
- No legacy Data Catalog resources
- Only supported `google_dataplex_*` resources

### ✅ Variable-Driven & Reusable
- Everything configurable via variables
- No hardcoded values
- Can be used by any team in your org
- Examples for every use case

## 🆚 Comparison with Other Modules

| Feature | This Module | Google Fabric | Auto DQ | drandell |
|---------|:-----------:|:-------------:|:-------:|:--------:|
| Lakes & Zones | ✅ | ✅ | ❌ | ✅ |
| Assets | ✅ | ✅ | ❌ | ✅ |
| DataScans | ✅ | ✅ | ✅ | ❌ |
| **Entry Groups** | ✅ | ❌ | ❌ | ❌ |
| **Entry Types** | ✅ | ❌ | ❌ | ❌ |
| **Tasks** | ✅ | ❌ | ❌ | ❌ |
| **Monitoring** | ✅ | ❌ | ❌ | ❌ |
| **Encryption** | ✅ | ❌ | ❌ | ❌ |
| Variable-Driven | ✅ | ✅ | ❌ | ❌ |

## 🏢 Usage in Organizations

### For Teams
Each team can use the modules independently:

```hcl
# Team A: Only needs lakes
module "my_lake" {
  source = "git::https://github.com/your-org/repo.git//modules/manage-lakes"
  # ... configuration
}

# Team B: Needs lakes + quality
module "my_lake" {
  source = "git::https://github.com/your-org/repo.git//modules/manage-lakes"
  # ... configuration
}

module "my_quality" {
  source = "git::https://github.com/your-org/repo.git//modules/govern"
  # ... configuration
}
```

### For Platform Teams
Create a wrapper module for your organization:

```hcl
# your-org-dataplex-module/main.tf
module "lakes" {
  source = "git::https://github.com/your-org/repo.git//modules/manage-lakes"
  # ... pass-through variables
}

module "metadata" {
  source = "git::https://github.com/your-org/repo.git//modules/manage-metadata"
  # ... pass-through variables
}

module "govern" {
  source = "git::https://github.com/your-org/repo.git//modules/govern"
  # ... pass-through variables
}
```

## 📚 Resources Created

### All Dataplex Resources (10)
- `google_dataplex_lake`
- `google_dataplex_zone`
- `google_dataplex_asset`
- `google_dataplex_task`
- `google_dataplex_datascan`
- `google_dataplex_entry_group`
- `google_dataplex_entry_type`
- `google_dataplex_entry`
- `google_dataplex_aspect_type`
- `google_dataplex_lake_iam_*`

### Supporting Resources
- BigQuery datasets/tables (for metadata & results)
- Cloud Storage buckets (for artifacts)
- KMS keys (for encryption)
- Service accounts (with proper IAM)
- Monitoring (dashboards, alerts, SLOs)
- Logging (sinks, metrics)

## 🔒 Security Best Practices

- ✅ KMS encryption for data at rest
- ✅ IAM bindings at lake level
- ✅ Service accounts with least privilege
- ✅ Audit logging enabled
- ✅ Security monitoring and alerts

## 🤝 Contributing

1. Each module must be self-contained
2. All variables must have descriptions and types
3. Include examples for new features
4. Update module README when adding features

## 📄 License

[Your License]

## 📞 Support

- Documentation: See individual module READMEs
- Issues: [GitHub Issues](https://github.com/your-org/repo/issues)
- Official Docs: [Dataplex Terraform Documentation](https://cloud.google.com/dataplex/docs/terraform)

## 🎖️ Credits

Built with ❤️ for production use. Based on [official Google Cloud Dataplex Terraform documentation](https://cloud.google.com/dataplex/docs/terraform).

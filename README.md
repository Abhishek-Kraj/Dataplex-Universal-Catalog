# Dataplex Universal Catalog - Terraform Module

A comprehensive, modular Terraform structure for deploying and managing Google Cloud Dataplex Universal Catalog with all its key features.

## 🏗️ Architecture Overview

This module provides a complete implementation of Dataplex Universal Catalog organized into four main feature modules:

```
dataplex-universal-catalog-tf-module/
├── modules/
│   ├── discover/              # Search, Taxonomy, Templates
│   ├── manage-metadata/       # Catalog, Glossaries
│   ├── manage-lakes/          # Lakes, Zones, Assets, Security, Processing
│   └── govern/                # Profiling, Quality, Monitoring
└── examples/
    ├── basic/                 # Minimal setup
    └── complete/              # Full-featured setup
```

## ✨ Features

### 🔍 Discover Module
- **Search**: Dataplex search configuration and metadata storage
- **Taxonomy**: Data classification with policy tags and hierarchical organization
- **Templates**: Metadata templates for assets, tables, and columns

### 📚 Manage Metadata Module
- **Catalog**: Entry groups, entry types, and aspect types for data assets
- **Glossaries**: Business glossary with terms, relationships, and hierarchies

### 🏞️ Manage Lakes Module
- **Manage**: Lakes, zones (RAW/CURATED), and assets (GCS buckets, BigQuery datasets)
- **Secure**: IAM bindings, KMS encryption, audit logging, security monitoring
- **Process**: Spark jobs, data processing tasks, notebooks

### 🛡️ Govern Module
- **Profiling**: Data profiling scans with statistics and metrics
- **Quality**: Data quality scans with customizable rules and dimensions
- **Monitoring**: Dashboards, alerts, SLOs, and log-based metrics

## 🚀 Quick Start

### Prerequisites

1. GCP Project with billing enabled
2. Required APIs enabled:
   - Dataplex API
   - Data Catalog API
   - BigQuery API
   - Cloud Storage API
   - Cloud KMS API
   - Cloud Monitoring API

3. Terraform >= 1.3

### Enable Required APIs

```bash
gcloud services enable dataplex.googleapis.com \
  datacatalog.googleapis.com \
  bigquery.googleapis.com \
  storage.googleapis.com \
  cloudkms.googleapis.com \
  monitoring.googleapis.com
```

### Basic Usage

```hcl
module "dataplex" {
  source = "github.com/yourusername/dataplex-universal-catalog-tf-module"

  project_id = "your-gcp-project-id"
  region     = "us-central1"
  location   = "us-central1"

  # Enable desired features
  enable_discover        = true
  enable_manage_metadata = true
  enable_manage_lakes    = true
  enable_govern          = true

  # Configure lakes
  manage_lakes_config = {
    lakes = [
      {
        lake_id      = "analytics-lake"
        display_name = "Analytics Lake"
        zones = [
          {
            zone_id = "raw-zone"
            type    = "RAW"
          },
          {
            zone_id = "curated-zone"
            type    = "CURATED"
          }
        ]
      }
    ]
  }

  labels = {
    environment = "production"
    managed_by  = "terraform"
  }
}
```

## 📖 Examples

### Basic Example

Minimal setup with essential features:

```bash
cd examples/basic
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your project details
terraform init
terraform plan
terraform apply
```

### Complete Example

Full-featured setup with all modules and configurations:

```bash
cd examples/complete
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your project details
terraform init
terraform plan
terraform apply
```

## 🔧 Module Configuration

### Feature Toggles

Enable or disable specific modules:

```hcl
enable_discover        = true  # Search, Taxonomy, Templates
enable_manage_metadata = true  # Catalog, Glossaries
enable_manage_lakes    = true  # Lakes, Zones, Security, Processing
enable_govern          = true  # Profiling, Quality, Monitoring
```

### Discover Configuration

```hcl
discover_config = {
  enable_search         = true
  enable_taxonomy       = true
  enable_templates      = true
  search_scope          = "PROJECT"
  search_result_limit   = 100
  taxonomy_display_name = "Data Taxonomy"
  policy_tags           = ["Confidential", "Public", "Internal", "PII"]
}
```

### Manage Metadata Configuration

```hcl
manage_metadata_config = {
  enable_catalog    = true
  enable_glossaries = true
  entry_groups = [
    {
      entry_group_id = "customer-data"
      display_name   = "Customer Data"
      description    = "Customer information"
    }
  ]
  glossaries = [
    {
      glossary_id  = "business-glossary"
      display_name = "Business Glossary"
      terms = [
        {
          term_id      = "customer"
          display_name = "Customer"
          description  = "Individual or organization purchasing products"
        }
      ]
    }
  ]
}
```

### Manage Lakes Configuration

```hcl
manage_lakes_config = {
  enable_manage  = true
  enable_secure  = true
  enable_process = true
  lakes = [
    {
      lake_id      = "analytics-lake"
      display_name = "Analytics Lake"
      zones = [
        {
          zone_id      = "raw-zone"
          type         = "RAW"
          display_name = "Raw Data Zone"
        }
      ]
    }
  ]
  iam_bindings = [
    {
      lake_id = "analytics-lake"
      role    = "roles/dataplex.viewer"
      members = ["group:analysts@example.com"]
    }
  ]
  spark_jobs = [
    {
      job_id       = "data-transformation"
      lake_id      = "analytics-lake"
      main_class   = "com.example.Transform"
      main_jar_uri = "gs://bucket/transform.jar"
    }
  ]
}
```

### Govern Configuration

```hcl
govern_config = {
  enable_profiling  = true
  enable_quality    = true
  enable_monitoring = true
  quality_scans = [
    {
      scan_id      = "customer-quality"
      lake_id      = "analytics-lake"
      data_source  = "//bigquery.googleapis.com/projects/PROJECT/datasets/customers"
      rules = [
        {
          rule_type  = "NON_NULL"
          column     = "customer_id"
          threshold  = 1.0
          dimension  = "COMPLETENESS"
        }
      ]
    }
  ]
  profiling_scans = [
    {
      scan_id      = "customer-profile"
      lake_id      = "analytics-lake"
      data_source  = "//bigquery.googleapis.com/projects/PROJECT/datasets/customers"
    }
  ]
}
```

## 📊 Outputs

The module provides comprehensive outputs for all created resources:

```hcl
# Discover Module
output "discover_taxonomy_id"      # Taxonomy ID
output "discover_policy_tags"      # Map of policy tags
output "discover_search_config"    # Search configuration

# Manage Metadata Module
output "entry_groups"              # Entry groups details
output "glossaries"                # Glossaries details
output "glossary_terms"            # Glossary terms

# Manage Lakes Module
output "lakes"                     # Lakes details
output "zones"                     # Zones details
output "assets"                    # Assets details
output "spark_jobs"                # Spark jobs details

# Govern Module
output "quality_scans"             # Quality scans details
output "profiling_scans"           # Profiling scans details
output "monitoring_dashboards"     # Dashboard IDs

# Module Status
output "module_status"             # Enabled modules status
```

## 🔐 Security Features

### IAM & Access Control
- Lake-level IAM bindings
- Service accounts with least privilege
- Time-based access conditions
- Audit logging for all operations

### Encryption
- KMS encryption keys for data at rest
- Automatic key rotation (90 days)
- Encrypted buckets and datasets

### Monitoring & Compliance
- Security event logging
- Audit log sinks to BigQuery
- Alert policies for security events
- SLO tracking for data quality

## 📈 Data Quality & Governance

### Quality Dimensions
- **Completeness**: Non-null checks, required fields
- **Accuracy**: Range validations, format checks
- **Validity**: Regex patterns, set expectations
- **Consistency**: Cross-table validations
- **Uniqueness**: Duplicate detection

### Quality Rules
```hcl
rules = [
  {
    rule_type  = "NON_NULL"      # Null value check
    rule_type  = "RANGE"         # Value range check
    rule_type  = "REGEX"         # Pattern matching
    rule_type  = "SET"           # Value set validation
    rule_type  = "UNIQUENESS"    # Duplicate check
  }
]
```

### Data Profiling
- Column-level statistics
- Data type detection
- Null percentages
- Distinct value counts
- Min/Max/Mean/Median values
- Standard deviation

## 🎯 Best Practices

### Resource Naming
- Use consistent naming conventions
- Include environment in resource names
- Apply descriptive labels

### Cost Optimization
- Disable unused modules with feature toggles
- Set appropriate scan schedules
- Configure data retention policies
- Use lifecycle rules for GCS buckets

### Scalability
- Use dynamic resource creation with `for_each`
- Leverage module composition
- Separate environments with workspaces

### Monitoring
- Set up alert policies for critical metrics
- Create custom dashboards
- Monitor scan execution status
- Track quality score trends

## 🛠️ Troubleshooting

### Common Issues

**API Not Enabled**
```bash
gcloud services enable dataplex.googleapis.com
```

**Insufficient Permissions**
```bash
# Required roles:
# - roles/dataplex.admin
# - roles/datacatalog.admin
# - roles/bigquery.admin
# - roles/storage.admin
```

**Resource Dependencies**
- Ensure lakes exist before creating scans
- Create entry groups before entries
- Set up proper `depends_on` relationships

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

This module is licensed under the MIT License.

## 🆘 Support

For issues and questions:
- Open an issue in the GitHub repository
- Check the [examples](./examples/) directory
- Review GCP Dataplex documentation

## 📚 Additional Resources

- [Google Cloud Dataplex Documentation](https://cloud.google.com/dataplex/docs)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Data Governance Best Practices](https://cloud.google.com/architecture/data-governance)

## 🗺️ Roadmap

- [ ] Add support for Data Lineage tracking
- [ ] Implement automated remediation workflows
- [ ] Add pre-commit hooks for Terraform validation
- [ ] Create CI/CD pipeline examples
- [ ] Add cost estimation module

---

**Made with ❤️ for Data Engineers and Platform Teams**

# Variables Configuration Guide

Complete guide to all configurable variables in the Dataplex Universal Catalog Terraform module.

## Table of Contents
- [Core Variables](#core-variables)
- [Feature Toggles](#feature-toggles)
- [Discover Module](#discover-module)
- [Manage Metadata Module](#manage-metadata-module)
- [Manage Lakes Module](#manage-lakes-module)
- [Govern Module](#govern-module)
- [Labels and Tags](#labels-and-tags)

---

## Core Variables

### `project_id` (Required)
- **Type**: `string`
- **Description**: Your GCP project ID
- **Example**: `"my-gcp-project-123"`

### `region`
- **Type**: `string`
- **Default**: `"us-central1"`
- **Description**: GCP region for resources
- **Options**:
  - `"us-central1"` - Iowa, USA
  - `"us-east1"` - South Carolina, USA
  - `"europe-west1"` - Belgium
  - `"asia-southeast1"` - Singapore
  - `"asia-northeast1"` - Tokyo
  - `"australia-southeast1"` - Sydney

### `location`
- **Type**: `string`
- **Default**: `"us-central1"`
- **Description**: GCP location (usually same as region)

---

## Feature Toggles

Enable or disable entire modules:

```hcl
enable_discover        = true  # Discover module
enable_manage_metadata = true  # Manage Metadata module
enable_manage_lakes    = true  # Manage Lakes module
enable_govern          = true  # Govern module
```

---

## Discover Module

Configure search, taxonomy, and metadata templates.

### Configuration Object: `discover_config`

```hcl
discover_config = {
  enable_search          = bool      # Enable search functionality
  enable_taxonomy        = bool      # Enable taxonomy management
  enable_templates       = bool      # Enable metadata templates
  search_scope           = string    # "PROJECT" or "ORGANIZATION"
  search_result_limit    = number    # Max results (1-1000)
  taxonomy_display_name  = string    # Display name for taxonomy
  policy_tags            = list(string)  # List of policy tags
}
```

### Example

```hcl
discover_config = {
  enable_search         = true
  enable_taxonomy       = true
  enable_templates      = true
  search_scope          = "PROJECT"
  search_result_limit   = 100
  taxonomy_display_name = "Enterprise Data Taxonomy"

  policy_tags = [
    "Highly-Confidential",
    "Confidential",
    "Internal",
    "Public",
    "PII",
    "PCI",
    "PHI"
  ]
}
```

### Policy Tags Categories

**Security Classifications:**
- `"Public"` - Publicly available data
- `"Internal"` - Internal use only
- `"Confidential"` - Confidential business data
- `"Highly-Confidential"` - Top secret data
- `"Restricted"` - Restricted access data

**Compliance Tags:**
- `"PII"` - Personally Identifiable Information
- `"PCI"` - Payment Card Industry data
- `"PHI"` - Protected Health Information
- `"GDPR"` - GDPR regulated data
- `"SOX"` - Sarbanes-Oxley regulated data

**Business Tags:**
- `"Financial-Data"` - Financial information
- `"Customer-Data"` - Customer information
- `"Product-Data"` - Product information

---

## Manage Metadata Module

Configure entry groups and business glossaries.

### Configuration Object: `manage_metadata_config`

```hcl
manage_metadata_config = {
  enable_catalog    = bool
  enable_glossaries = bool
  entry_groups      = list(object)
  glossaries        = list(object)
}
```

### Entry Groups

```hcl
entry_groups = [
  {
    entry_group_id = string  # Unique ID (lowercase, hyphens)
    display_name   = string  # Human-readable name
    description    = string  # Description
  }
]
```

**Example Entry Groups:**
```hcl
entry_groups = [
  {
    entry_group_id = "customer-data"
    display_name   = "Customer Data"
    description    = "Customer information and analytics"
  },
  {
    entry_group_id = "product-catalog"
    display_name   = "Product Catalog"
    description    = "Product inventory and details"
  }
]
```

### Glossaries

```hcl
glossaries = [
  {
    glossary_id  = string
    display_name = string
    description  = string
    terms = [
      {
        term_id      = string
        display_name = string
        description  = string
      }
    ]
  }
]
```

**Example Glossary:**
```hcl
glossaries = [
  {
    glossary_id  = "business-glossary"
    display_name = "Business Glossary"
    description  = "Enterprise business terms"
    terms = [
      {
        term_id      = "customer-lifetime-value"
        display_name = "Customer Lifetime Value (CLV)"
        description  = "Total revenue expected from a customer"
      },
      {
        term_id      = "churn-rate"
        display_name = "Churn Rate"
        description  = "% of customers who stop using service"
      }
    ]
  }
]
```

---

## Manage Lakes Module

Configure data lakes, zones, security, and processing.

### Configuration Object: `manage_lakes_config`

```hcl
manage_lakes_config = {
  enable_manage  = bool
  enable_secure  = bool
  enable_process = bool
  lakes          = list(object)
  iam_bindings   = list(object)
  spark_jobs     = list(object)
}
```

### Lakes and Zones

```hcl
lakes = [
  {
    lake_id      = string
    display_name = string
    description  = string
    labels       = map(string)
    zones = [
      {
        zone_id       = string
        type          = string  # "RAW" or "CURATED"
        display_name  = string
        description   = string
        location_type = string  # "SINGLE_REGION" or "MULTI_REGION"
      }
    ]
  }
]
```

**Zone Types:**
- `"RAW"` - Raw, unprocessed data
- `"CURATED"` - Cleaned, validated data

**Example:**
```hcl
lakes = [
  {
    lake_id      = "analytics-lake"
    display_name = "Analytics Lake"
    description  = "Central analytics data lake"
    labels = {
      domain = "analytics"
      criticality = "high"
    }
    zones = [
      {
        zone_id       = "bronze-zone"
        type          = "RAW"
        display_name  = "Bronze Zone"
        description   = "Raw ingestion zone"
        location_type = "SINGLE_REGION"
      },
      {
        zone_id       = "silver-zone"
        type          = "CURATED"
        display_name  = "Silver Zone"
        description   = "Cleaned and validated data"
        location_type = "SINGLE_REGION"
      },
      {
        zone_id       = "gold-zone"
        type          = "CURATED"
        display_name  = "Gold Zone"
        description   = "Business-ready aggregated data"
        location_type = "SINGLE_REGION"
      }
    ]
  }
]
```

### IAM Bindings

```hcl
iam_bindings = [
  {
    lake_id = string
    role    = string
    members = list(string)
  }
]
```

**Common Roles:**
- `"roles/dataplex.viewer"` - Read-only access
- `"roles/dataplex.editor"` - Read and write access
- `"roles/dataplex.admin"` - Full administrative access
- `"roles/dataplex.dataReader"` - Data read access
- `"roles/dataplex.dataWriter"` - Data write access

**Example:**
```hcl
iam_bindings = [
  {
    lake_id = "analytics-lake"
    role    = "roles/dataplex.viewer"
    members = [
      "group:data-analysts@example.com",
      "group:business-users@example.com"
    ]
  },
  {
    lake_id = "analytics-lake"
    role    = "roles/dataplex.editor"
    members = [
      "group:data-engineers@example.com",
      "serviceAccount:etl-pipeline@project.iam.gserviceaccount.com"
    ]
  }
]
```

### Spark Jobs

```hcl
spark_jobs = [
  {
    job_id       = string
    lake_id      = string
    display_name = string
    description  = string
    main_class   = string
    main_jar_uri = string
    args         = list(string)
  }
]
```

**Example:**
```hcl
spark_jobs = [
  {
    job_id       = "customer-etl"
    lake_id      = "analytics-lake"
    display_name = "Customer Data ETL"
    description  = "Extract and transform customer data"
    main_class   = "com.example.CustomerETL"
    main_jar_uri = "gs://my-bucket/jars/customer-etl.jar"
    args         = ["--input=raw", "--output=curated", "--date=${today}"]
  }
]
```

---

## Govern Module

Configure data profiling, quality checks, and monitoring.

### Configuration Object: `govern_config`

```hcl
govern_config = {
  enable_profiling  = bool
  enable_quality    = bool
  enable_monitoring = bool
  quality_scans     = list(object)
  profiling_scans   = list(object)
}
```

### Quality Scans

```hcl
quality_scans = [
  {
    scan_id      = string
    lake_id      = string
    display_name = string
    description  = string
    data_source  = string  # BigQuery resource name
    rules = [
      {
        rule_type  = string   # Rule type
        column     = string   # Column name (optional for table-level rules)
        threshold  = number   # Threshold (0.0-1.0)
        dimension  = string   # Quality dimension
      }
    ]
  }
]
```

**Rule Types:**
1. `"NON_NULL"` - Check for null values
2. `"UNIQUENESS"` - Check for duplicates
3. `"RANGE"` - Validate value ranges
4. `"REGEX"` - Pattern matching
5. `"SET"` - Value must be in predefined set

**Quality Dimensions:**
- `"COMPLETENESS"` - Data completeness
- `"ACCURACY"` - Data accuracy
- `"CONSISTENCY"` - Data consistency
- `"VALIDITY"` - Data validity
- `"UNIQUENESS"` - Data uniqueness
- `"TIMELINESS"` - Data freshness

**Example:**
```hcl
quality_scans = [
  {
    scan_id      = "customer-quality"
    lake_id      = "analytics-lake"
    display_name = "Customer Data Quality"
    description  = "Quality checks for customer master data"
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
      },
      {
        rule_type  = "RANGE"
        column     = "age"
        threshold  = 0.95
        dimension  = "VALIDITY"
      },
      {
        rule_type  = "SET"
        column     = "status"
        threshold  = 1.0
        dimension  = "VALIDITY"
      }
    ]
  }
]
```

### Profiling Scans

```hcl
profiling_scans = [
  {
    scan_id      = string
    lake_id      = string
    display_name = string
    description  = string
    data_source  = string
  }
]
```

**Example:**
```hcl
profiling_scans = [
  {
    scan_id      = "customer-profile"
    lake_id      = "analytics-lake"
    display_name = "Customer Data Profile"
    description  = "Statistical profiling of customer data"
    data_source  = "//bigquery.googleapis.com/projects/my-project/datasets/customers/tables/customer_master"
  }
]
```

---

## Labels and Tags

### Labels

Applied to all GCP resources for organization and billing.

```hcl
labels = {
  environment  = "production"    # Environment: dev, staging, prod
  managed_by   = "terraform"     # Management tool
  project      = "data-platform" # Project name
  cost_center  = "engineering"   # Cost allocation
  owner        = "data-team"     # Ownership
  compliance   = "gdpr"          # Compliance requirements
}
```

**Common Label Keys:**
- `environment` - dev, staging, production
- `managed_by` - terraform, manual, automated
- `project` - Project identifier
- `cost_center` - For cost allocation
- `owner` - Team or individual owner
- `compliance` - Compliance requirements
- `criticality` - low, medium, high, critical
- `data_classification` - public, internal, confidential

### Tags

Additional metadata for resources.

```hcl
tags = {
  backup_required     = "true"
  monitoring_enabled  = "true"
  encryption_required = "true"
}
```

---

## Complete Example

See `terraform.tfvars.example` for a comprehensive configuration example with all available options.

---

## Variable Validation

The module includes built-in validation for:
- ✅ Search scope (PROJECT/ORGANIZATION)
- ✅ Search result limits (1-1000)
- ✅ Zone types (RAW/CURATED)
- ✅ Quality rule thresholds (0.0-1.0)

Invalid values will produce clear error messages during `terraform plan`.

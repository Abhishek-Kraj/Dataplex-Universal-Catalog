# [RFC] Dataplex Universal Catalog for GCP ISS Foundation

**Author:** Data Platform Team
**State:** Draft
**Version:** 1.0
**Date:** 2025-01-08

---

## Revision History

| Date | Version | Description | Author |
|------|---------|-------------|--------|
| 08 Jan 2025 | 1.0 | Initial version for GCP Dataplex Universal Catalog onboarding | Data Platform Team |

---

## Document Review and Approval

| Date | Version | Reviewer | Comments |
|------|---------|----------|----------|
| ___ | 1.0 | Security Team | Pending |
| ___ | 1.0 | Architecture Team | Pending |
| ___ | 1.0 | Compliance Team | Pending |

---

## 1. Introduction

### 1.1. Document Purpose

| Purpose | To describe deployment process of GCP Dataplex Universal Catalog resources through Infrastructure as Code (IaC) using Terraform Resources from the Google Cloud provider. |
|---------|------|
| **Intended Audience** | A technologist audience with familiarity of data cataloging, data governance, GCP Dataplex, and Terraform on Google Cloud. |
| **Key Assumptions** | The audience should have a basic understanding of GCP Dataplex, Terraform, IaC, Google Cloud, and ISS Foundation patterns. |

---

### 1.2. Objectives

The objectives of the implementation are to achieve the following:

- Simplify customer Developer team's experience for data cataloging and governance
- Introduce easy-to-use data catalog that organizes and governs data across GCS buckets and BigQuery datasets
- Enable data quality monitoring and profiling capabilities
- Provide business glossaries for data asset documentation
- Integrate seamlessly with ISS Foundation infrastructure patterns

---

### 1.3. Definitions

| Term | Definition |
|------|------------|
| **GCP** | Google Cloud Platform |
| **VCS** | Version Control System |
| **VPC** | Virtual Private Cloud |
| **CI/CD** | Continuous Integration / Continuous Delivery |
| **IaC** | Infrastructure as Code |
| **CMEK** | Customer-Managed Encryption Keys |
| **ISS** | Infrastructure Self Service |
| **IAM** | Identity and Access Management |
| **CDC** | Change Data Capture |
| **Dataplex Lake** | Top-level organizational unit containing zones |
| **Dataplex Zone** | Subdivision of a lake (RAW or CURATED) |
| **Dataplex Asset** | Reference to GCS bucket or BigQuery dataset |
| **Entry Group** | Logical grouping of catalog entries |
| **Entry Type** | Template defining entry structure |
| **Aspect Type** | Custom metadata fields for entries |
| **Quality Scan** | Data quality validation rules |
| **Profiling Scan** | Statistical analysis of data |

---

### 1.4. About Dataplex

Google Cloud Dataplex is a unified data management service that helps you organize, catalog, and govern your data across data lakes and data warehouses. Dataplex provides a single pane of glass for managing data at scale.

**Key Capabilities:**

- **Data Organization**: Organize data into lakes, zones, and assets
- **Metadata Catalog**: Catalog entries with entry groups, types, and aspect types
- **Data Discovery**: Search and discover data assets across the organization
- **Data Quality**: Automated data quality checks with validation rules
- **Data Profiling**: Statistical analysis and profiling of datasets
- **Business Glossaries**: Document business terms and definitions
- **Data Lineage**: Track data flow and transformations (future capability)

**Some benefits of Dataplex:**

- Centralized data catalog for all GCS and BigQuery resources
- Automated metadata discovery and indexing
- Built-in data quality and profiling capabilities
- Integration with other GCP data services (BigQuery, Cloud Storage, Datastream, Dataflow)
- Serverless, fully-managed service (no infrastructure to manage)
- Built-in security with IAM controls and encryption

---

## 2. Architecture Drivers

### 2.1. User Stories

**As a Developer**, I want to use Infrastructure Self-Service framework to enable GCP Dataplex API and resources in GCP project using terraform module from gcp-foundation repository.

**As a Developer**, I want to have ability to catalog existing GCS buckets and BigQuery datasets created by ISS Foundation built-in modules (`builtin_gcs_v2.tf`, `builtin_bigquery.tf`).

**As a Data Engineer**, I want to organize data assets into logical lakes and zones (RAW vs CURATED) for better data governance.

**As a Data Analyst**, I want to search and discover data assets using metadata catalog with business glossaries.

**As a Data Quality Engineer**, I want to configure automated data quality scans to validate data completeness, uniqueness, and validity.

**As a Compliance Officer**, I want to ensure all data assets are properly cataloged with metadata for audit and compliance purposes.

---

### 2.2. Use Cases

#### 2.2.1. Data Cataloging and Organization

![Data Cataloging Flow](https://i.imgur.com/placeholder.png)

**Scenario**: A data engineering team has multiple GCS buckets and BigQuery datasets created by ISS Foundation. They need to organize and catalog these resources for discoverability.

**Solution**:
- Create Dataplex lakes to represent different data domains (e.g., "Customer Data Lake", "Financial Data Lake")
- Create RAW zones for landing/ingestion data and CURATED zones for processed data
- Create Dataplex assets that reference existing GCS buckets and BigQuery datasets
- Dataplex automatically discovers and indexes metadata

**Example**:
```
Analytics Lake
├── RAW Zone (Ingestion)
│   ├── Asset: gs://raw-customer-data
│   └── Asset: gs://raw-transaction-data
└── CURATED Zone (Processed)
    ├── Asset: BigQuery Dataset: analytics_warehouse
    └── Asset: BigQuery Dataset: customer_360
```

---

#### 2.2.2. Data Quality Monitoring

**Scenario**: A data quality team needs to ensure customer data meets quality standards before being used by downstream analytics.

**Solution**:
- Configure data quality scans on BigQuery tables
- Define validation rules:
  - NON_NULL: Check for missing values in critical columns
  - UNIQUENESS: Verify unique customer IDs
  - REGEX: Validate email format
  - RANGE: Check age values are within valid range
  - SET_MEMBERSHIP: Validate status values are in allowed list
- Schedule scans to run daily/weekly
- Monitor scan results in BigQuery

**Example Rules**:
```hcl
quality_scans = [{
  scan_id = "customer-quality"
  data_source = "//bigquery.googleapis.com/projects/PROJECT/datasets/analytics/tables/customers"
  rules = [
    { rule_type = "NON_NULL", column = "customer_id", threshold = 1.0 },
    { rule_type = "UNIQUENESS", column = "customer_id", threshold = 1.0 },
    { rule_type = "REGEX", column = "email", pattern = "^[a-zA-Z0-9._%+-]+@...", threshold = 0.95 }
  ]
  schedule = "0 2 * * *"  # Daily at 2 AM
}]
```

---

#### 2.2.3. Business Glossary for Data Governance

**Scenario**: A data governance team needs to document business definitions for data terms to ensure consistent understanding across the organization.

**Solution**:
- Create business glossaries with terms and definitions
- Link glossary terms to data assets
- Provide searchable business vocabulary

**Example**:
```hcl
glossaries = [{
  glossary_id = "insurance-terms"
  terms = [
    {
      term_id = "policy"
      display_name = "Insurance Policy"
      description = "A contract between insurer and policyholder providing coverage"
    },
    {
      term_id = "claim"
      display_name = "Insurance Claim"
      description = "A formal request for coverage or compensation under a policy"
    }
  ]
}]
```

---

#### 2.2.4. Integration with Datastream CDC Pipeline

**Scenario**: Data is replicated from Cloud SQL to BigQuery using Datastream (CDC). The BigQuery datasets need to be cataloged and governed.

**Solution**:
- Datastream replicates data from Cloud SQL → BigQuery
- Dataplex catalogs the BigQuery datasets created by Datastream
- Data quality scans validate the replicated data
- Business glossaries document the data definitions

**Flow**:
```
Cloud SQL (Source)
    ↓
Datastream (CDC Replication)
    ↓
BigQuery Dataset (Destination)
    ↓
Dataplex (Cataloging & Governance)
    ├── Asset Registration
    ├── Quality Scans
    └── Business Glossary
```

---

### 2.3. Requirements

| # | Requirement Description |
|---|-------------------------|
| **R-1** | Implemented solution must be end-to-end automated using Terraform |
| **R-2** | Module must follow ISS Foundation patterns (catalog-only, no storage creation) |
| **R-3** | Module must use org-wide CMEK encryption managed by ISS Foundation |
| **R-4** | Solution must support cataloging existing GCS buckets created by `builtin_gcs_v2.tf` |
| **R-5** | Solution must support cataloging existing BigQuery datasets created by `builtin_bigquery.tf` |
| **R-6** | Solution must support both RAW zones (unprocessed data) and CURATED zones (processed data) |
| **R-7** | Solution must support data quality scans with 5 rule types (NON_NULL, UNIQUENESS, REGEX, RANGE, SET_MEMBERSHIP) |
| **R-8** | Solution must support data profiling scans for statistical analysis |
| **R-9** | Solution must support business glossaries for data governance |
| **R-10** | Solution must support metadata catalog with entry groups, entry types, and aspect types |
| **R-11** | Solution must integrate with Cloud Audit Logs for all operations |
| **R-12** | Solution must use Google-managed Dataplex service account (no custom SAs) |
| **R-13** | Solution must support IAM bindings at lake level for access control |
| **R-14** | Documentation must be provided for all modules and use cases |

---

### 2.4. Constraints

| # | Constraint Description |
|---|------------------------|
| **CON-1** | This module does NOT create GCS buckets or BigQuery datasets - it only catalogs existing resources |
| **CON-2** | RAW zones support any data format (GCS) and any data (BigQuery) |
| **CON-3** | CURATED zones require structured formats (Parquet/Avro/ORC for GCS) and schema for BigQuery |
| **CON-4** | Quality scans and profiling scans only work with BigQuery tables (not GCS files directly) |
| **CON-5** | Business glossaries are stored as BigQuery tables (native Dataplex glossaries not available in Terraform) |
| **CON-6** | All Dataplex resources (lakes, zones, assets) must be in the same GCP region |
| **CON-7** | Module does NOT manage encryption keys - inherits from ISS Foundation org-wide CMEK |
| **CON-8** | Module does NOT create custom service accounts - uses Google-managed Dataplex SA |
| **CON-9** | Data quality scan results contain statistics only, not actual data values |
| **CON-10** | GCS buckets and BigQuery datasets must exist before Dataplex assets can reference them |

---

### 2.5. Assumptions

- Customer's Google Cloud Organization and Google Cloud account with active billing already exists
- Service Account used for deploying Terraform resources has sufficient permissions
- Customer-managed encryption keys (CMEK) already exist and are managed by ISS Foundation at org level
- GCS buckets and BigQuery datasets are already created via ISS Foundation built-in modules
- No custom service accounts are needed (Google-managed Dataplex SA is sufficient)
- ISS Foundation handles all encryption, IAM for storage resources
- Network connectivity is not a concern (Dataplex is serverless, uses Google private network)

---

### 2.6. Limitations

**Dataplex Service Limitations:**

- Dataplex is a **regional** service - all resources must be in same region
- Quality scans only work on **BigQuery tables** (not direct GCS file scanning)
- Profiling scans only work on **BigQuery tables**
- Business glossaries stored as BigQuery tables (workaround for lack of native Terraform support)
- No built-in data lineage tracking (future capability)
- Entry groups, types, and aspect types are in **Preview** (may have limited functionality)

**Terraform Module Limitations:**

- Module uses `for_each` patterns (no hardcoded limits on resources)
- Subject to GCP Dataplex API quotas (see section 2.7)
- Module does NOT handle Spark/Dataproc tasks (`enable_process = false`)
- Module does NOT create custom IAM policies outside Dataplex scope

**Data Quality Scan Limitations:**

- Scans read data values for validation (PII considerations)
- Scan results contain statistics, not raw data
- Maximum table size for quality scans: ~1TB (performance considerations)
- Scans may impact BigQuery slot usage

**Integration Limitations:**

- Assets must reference storage in the **same GCP project** as Dataplex resources
- No cross-project asset cataloging (GCP limitation)
- No multi-region support (all resources must be in single region)

For detailed limitations, see:
- [Dataplex Quotas and Limits](https://cloud.google.com/dataplex/docs/quotas)
- [Data Quality Limitations](https://cloud.google.com/dataplex/docs/data-quality-overview#limitations)

---

### 2.7. Quotas and Limits

**GCP Dataplex Quotas (Per Project, Per Region):**

| Resource Type | Default Quota | Notes |
|---------------|---------------|-------|
| **Lakes** | 20 | Contact support for increase |
| **Zones per Lake** | 20 | Contact support for increase |
| **Assets per Zone** | 10,000 | Sufficient for most use cases |
| **Data Scans (on-demand)** | 100 | Quality + profiling combined |
| **Data Scans (scheduled)** | 100 | Recurring scans |
| **Entry Groups** | 1,000 | Per project |
| **Entry Types** | 1,000 | Per project |
| **Aspect Types** | 1,000 | Per project |

**API Request Limits:**

| API Operation | Limit | Scope |
|---------------|-------|-------|
| **Entry Read Requests** | 6,000/minute | Per project, per region |
| **Entry Write Requests** | 1,500/minute | Per project, per region |
| **Search Requests** | 1,200/minute | Per project |
| **Search Requests** | 2,400/minute | Per organization |

**System Limits (Cannot Be Changed):**

| Resource | Limit | Type |
|----------|-------|------|
| **Aspects per Entry** | 10,000 | System |
| **Entry Size** | 5 MB | System |
| **Entry ID Length** | 4,000 characters | System |
| **Search Results** | 500 items | System |

---

### 2.8. Final Deliverables

The customer will achieve an easy-to-use data catalog and governance service, consisting of Google Cloud Dataplex resources managed through IaC (Terraform). List of deliverables will include:

1. **Terraform Module**: `builtin_dataplex.tf` for ISS Foundation Level 3 runtime
2. **Module Documentation**: Complete README with architecture, usage, examples
3. **Security Discovery Document**: Comprehensive security analysis for security team approval
4. **ISS Integration Guide**: Step-by-step integration with ISS Foundation
5. **Example Configurations**: Complete tfvars examples showing all features
6. **Validation Examples**: Data quality and profiling scan examples
7. **Best Practices Guide**: Security, governance, and operational best practices

For deploying these resources, existing Jenkins pipeline will be used (standard ISS Foundation deployment).

---

### 2.9. Out of Scope for This Implementation

Current implementation does **NOT** include:

- Creating or managing GCS buckets (use `builtin_gcs_v2.tf`)
- Creating or managing BigQuery datasets (use `builtin_bigquery.tf`)
- Managing encryption keys (ISS Foundation handles org-wide CMEK)
- Creating or managing custom service accounts (uses Google-managed SA)
- Configuring Spark/Dataproc tasks (`enable_process = false`)
- Custom Jenkins pipelines (uses existing ISS Foundation pipelines)
- Data ingestion or ETL pipelines (use Datastream, Dataflow, etc.)
- Network configuration (Dataplex is serverless)
- Cross-project or multi-region deployments

---

## 3. Dataplex Solution Architecture

### 3.1. Big Picture

**General details of suggested design:**

- Dataplex resources will be created in end-user's app-ref Google Cloud Project
- GCS buckets and BigQuery datasets are created by ISS Foundation built-in modules
- Dataplex module **only catalogs** existing resources (catalog-only pattern)
- App-ref project can have multiple Dataplex lakes configured
- Each lake can have multiple zones (RAW and CURATED)
- Each zone can have multiple assets (buckets or datasets)

**Required resources for running Dataplex:**

1. **Dataplex API** (`dataplex.googleapis.com`)
2. **Data Catalog API** (`datacatalog.googleapis.com`)
3. **BigQuery API** (`bigquery.googleapis.com`) - for glossaries and scan results
4. **Cloud Storage API** (`storage-api.googleapis.com`) - for bucket discovery
5. **Dataplex Lakes** - Top-level organizational units
6. **Dataplex Zones** - RAW (unprocessed) or CURATED (processed)
7. **Dataplex Assets** - References to GCS buckets or BigQuery datasets
8. **Entry Groups** - Logical grouping for catalog entries
9. **Entry Types** - Templates defining entry structure
10. **Aspect Types** - Custom metadata fields
11. **Business Glossaries** - BigQuery tables with business terms
12. **Data Quality Scans** - Validation rules
13. **Data Profiling Scans** - Statistical analysis

**Architecture Diagram:**

```
┌─────────────────────────────────────────────────────────────────────────┐
│ ISS Foundation - Level 3 Runtime                                        │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────┐   │
│  │ builtin_gcs_v2.tf                                               │   │
│  │ Creates GCS Buckets:                                            │   │
│  │ • {lbu}-{env}-{stage}-{appref}-{az}-raw-data                   │   │
│  │ • {lbu}-{env}-{stage}-{appref}-{az}-curated-data              │   │
│  │ • Encrypted with org-wide CMEK                                  │   │
│  │ • Uniform bucket-level access                                   │   │
│  └────────────────────────────────────────────────────────────────┘   │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────┐   │
│  │ builtin_bigquery.tf                                             │   │
│  │ Creates BigQuery Datasets:                                      │   │
│  │ • analytics_warehouse                                           │   │
│  │ • customer_360                                                  │   │
│  │ • Encrypted with org-wide CMEK                                  │   │
│  │ • Dataset-level access controls                                 │   │
│  └────────────────────────────────────────────────────────────────┘   │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────┐   │
│  │ builtin_dataplex.tf (NEW)                                       │   │
│  │                                                                  │   │
│  │ ┌──────────────────────────────────────────────────────────┐  │   │
│  │ │ Dataplex Lake: analytics-lake                             │  │   │
│  │ │                                                            │  │   │
│  │ │  ┌─────────────────────────────────────────────────────┐ │  │   │
│  │ │  │ RAW Zone: raw-ingestion                              │ │  │   │
│  │ │  │ • Asset → gs://...raw-data                          │ │  │   │
│  │ │  │ • Metadata indexed automatically                     │ │  │   │
│  │ │  └─────────────────────────────────────────────────────┘ │  │   │
│  │ │                                                            │  │   │
│  │ │  ┌─────────────────────────────────────────────────────┐ │  │   │
│  │ │  │ CURATED Zone: analytics-warehouse                    │ │  │   │
│  │ │  │ • Asset → BigQuery: analytics_warehouse             │ │  │   │
│  │ │  │ • Schema discovered automatically                    │ │  │   │
│  │ │  └─────────────────────────────────────────────────────┘ │  │   │
│  │ └──────────────────────────────────────────────────────────┘  │   │
│  │                                                                  │   │
│  │ ┌──────────────────────────────────────────────────────────┐  │   │
│  │ │ Metadata Catalog                                          │  │   │
│  │ │ • Entry Groups (customer-data, financial-data)            │  │   │
│  │ │ • Entry Types (data-asset, table, report)                │  │   │
│  │ │ • Aspect Types (quality-score, owner, classification)     │  │   │
│  │ └──────────────────────────────────────────────────────────┘  │   │
│  │                                                                  │   │
│  │ ┌──────────────────────────────────────────────────────────┐  │   │
│  │ │ Business Glossaries                                       │  │   │
│  │ │ • Terms stored in BigQuery tables                         │  │   │
│  │ │ • Searchable via Data Catalog API                         │  │   │
│  │ └──────────────────────────────────────────────────────────┘  │   │
│  │                                                                  │   │
│  │ ┌──────────────────────────────────────────────────────────┐  │   │
│  │ │ Data Quality Scans                                        │  │   │
│  │ │ • NON_NULL, UNIQUENESS, REGEX, RANGE, SET_MEMBERSHIP     │  │   │
│  │ │ • Results stored in BigQuery (encrypted)                  │  │   │
│  │ │ • Scheduled execution (cron)                              │  │   │
│  │ └──────────────────────────────────────────────────────────┘  │   │
│  │                                                                  │   │
│  │ ┌──────────────────────────────────────────────────────────┐  │   │
│  │ │ Data Profiling Scans                                      │  │   │
│  │ │ • Statistical analysis (min, max, null%, distributions)   │  │   │
│  │ │ • Results stored in BigQuery                              │  │   │
│  │ └──────────────────────────────────────────────────────────┘  │   │
│  └────────────────────────────────────────────────────────────────┘   │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────────┐
│ Google-Managed Dataplex Service Account                                 │
│ service-{PROJECT_NUMBER}@gcp-sa-dataplex.iam.gserviceaccount.com       │
│                                                                          │
│ Permissions (granted by module):                                        │
│ • roles/bigquery.dataViewer - Read BigQuery data for quality scans     │
│ • roles/storage.objectViewer - Read GCS metadata for asset discovery    │
└─────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────────┐
│ Cloud Audit Logs                                                         │
│ • All Dataplex API calls logged (admin activity)                        │
│ • Data access logs (optional, recommended for sensitive data)           │
│ • Retention: 400 days (configurable)                                    │
└─────────────────────────────────────────────────────────────────────────┘
```

---

### 3.2. Proposal Details

This section contains additional information regarding the use-cases that will be supported in current implementation, and the end-user interface of the ISS built-in module description.

#### Key Design Principles:

1. **Catalog-Only Pattern**: Module does NOT create GCS buckets or BigQuery datasets. It only catalogs existing resources.

2. **ISS Foundation Integration**:
   - Storage created by `builtin_gcs_v2.tf` and `builtin_bigquery.tf`
   - Encryption managed by ISS Foundation (org-wide CMEK)
   - Dataplex references existing resources

3. **Separation of Concerns**:
   ```
   Infrastructure (ISS Foundation) → Storage Creation + Encryption
   Dataplex Module → Cataloging + Governance
   ```

4. **No Duplication**:
   - Single source of truth for infrastructure (ISS Foundation)
   - Dataplex adds metadata layer on top

#### Implementation Steps:

**Step 1: ISS Foundation Creates Storage**

```hcl
# In builtin_gcs_v2.tf (already exists)
gcs_buckets_v2 = {
  "raw-data" : {
    storage_class = "STANDARD"
    location      = "az1"
  }
}

# In builtin_bigquery.tf (already exists)
bigquery_datasets = {
  "analytics_warehouse" : {
    location = "az1"
    tables = [...]
  }
}
```

**Step 2: Add Dataplex Cataloging**

```hcl
# In builtin_dataplex.tf (NEW)
variable "dataplex_lakes" {
  type    = any
  default = {}
}

module "project_dataplex" {
  for_each = local.dataplex_lakes
  source   = "git::https://github.com/Abhishek-Kraj/Dataplex-Universal-Catalog.git?ref=feature/iss-foundation"

  project_id = local.project_id
  region     = local.availability_regions[lookup(each.value, "location", "az1")]
  location   = local.availability_regions[lookup(each.value, "location", "az1")]

  # ISS Foundation handles these
  enable_secure  = false  # No custom SAs
  enable_process = false  # No Spark jobs

  lakes = lookup(each.value, "lakes", [])
  entry_groups  = lookup(each.value, "entry_groups", [])
  glossaries    = lookup(each.value, "glossaries", [])
  quality_scans = lookup(each.value, "quality_scans", [])

  labels = {
    lbu    = local.lbu
    env    = local.env
    stage  = local.stage
    appref = local.appref
  }
}
```

**Step 3: Configure in tfvars**

```hcl
# In terraform.tfvars (app-ref project)
dataplex_lakes = {
  "analytics-catalog" : {
    location = "az1"

    lakes = [{
      lake_id = "analytics-lake"
      zones = [
        {
          zone_id         = "raw-ingestion"
          type            = "RAW"
          # Reference bucket created by builtin_gcs_v2.tf
          existing_bucket = "${LBU}-${ENV}-${STAGE}-${APPREF}-${AZ}-raw-data"
        },
        {
          zone_id          = "analytics-warehouse"
          type             = "CURATED"
          # Reference dataset created by builtin_bigquery.tf
          existing_dataset = "analytics_warehouse"
        }
      ]
    }]

    quality_scans = [{
      scan_id     = "customer-quality"
      lake_id     = "analytics-lake"
      data_source = "//bigquery.googleapis.com/projects/${PROJECT_ID}/datasets/analytics_warehouse/tables/customers"
      rules = [
        { rule_type = "NON_NULL", column = "customer_id", threshold = 1.0, dimension = "COMPLETENESS" }
      ]
      schedule = "0 2 * * *"
    }]
  }
}
```

---

### 3.3. Supported Use Cases

Based on ISS Foundation integration requirements, the following use cases are supported:

#### 3.3.1. Catalog-Only Pattern (Primary Use Case)

**Scenario**: ISS Foundation creates all storage infrastructure. Dataplex catalogs existing resources.

**Implementation**:
- GCS buckets created by `builtin_gcs_v2.tf` with org-wide CMEK
- BigQuery datasets created by `builtin_bigquery.tf` with org-wide CMEK
- Dataplex module references existing resources via `existing_bucket` / `existing_dataset`
- No storage creation in Dataplex module

**Benefits**:
- ✅ Single source of truth for infrastructure (ISS Foundation)
- ✅ Consistent encryption (org-wide CMEK)
- ✅ No configuration duplication
- ✅ Clear separation of concerns

#### 3.3.2. Data Quality Monitoring

**Scenario**: Validate data quality on BigQuery tables populated by Datastream CDC pipeline.

**Implementation**:
```hcl
quality_scans = [{
  scan_id     = "customer-quality"
  data_source = "//bigquery.googleapis.com/projects/PROJECT/datasets/customer_data/tables/customers"
  rules = [
    { rule_type = "NON_NULL", column = "customer_id", threshold = 1.0 },
    { rule_type = "UNIQUENESS", column = "customer_id", threshold = 1.0 },
    { rule_type = "REGEX", column = "email", pattern = "^[a-zA-Z0-9._%+-]+@...", threshold = 0.95 }
  ]
  schedule = "0 2 * * *"
}]
```

**Benefits**:
- ✅ Automated quality validation
- ✅ Early detection of data issues
- ✅ Quality metrics stored in BigQuery

#### 3.3.3. Business Glossary for Governance

**Scenario**: Document business terms for data assets across organization.

**Implementation**:
```hcl
glossaries = [{
  glossary_id = "insurance-terms"
  terms = [
    { term_id = "policy", display_name = "Insurance Policy", description = "..." },
    { term_id = "claim", display_name = "Insurance Claim", description = "..." }
  ]
}]
```

**Benefits**:
- ✅ Centralized business vocabulary
- ✅ Consistent data definitions
- ✅ Searchable via Data Catalog

#### 3.3.4. Metadata Catalog for Discovery

**Scenario**: Enable data analysts to search and discover data assets.

**Implementation**:
```hcl
entry_groups = [{
  entry_group_id = "customer-data"
  display_name   = "Customer Data Assets"
}]

aspect_types = [{
  aspect_type_id = "data-classification"
  metadata_template = {
    fields = [
      { field_id = "sensitivity", type = "ENUM", enum_values = ["PUBLIC", "CONFIDENTIAL", "RESTRICTED"] }
    ]
  }
}]
```

**Benefits**:
- ✅ Searchable data catalog
- ✅ Custom metadata tags
- ✅ Data classification

---

### 3.4. ISS Built-in Module Interface

As mentioned in section 3.2, to provision Dataplex resources user must fill the `terraform.tfvars` in related app-ref BitBucket repository and trigger Jenkins pipeline for provisioning Dataplex resources in GCP app-ref project.

**End-user Interface:**

```hcl
# terraform.tfvars in app-ref repository

# ============================================================================
# Dataplex Configuration
# ============================================================================

dataplex_lakes = {
  "analytics-catalog" : {
    location = "az1"  # Must match region where buckets/datasets are created

    # Feature toggles
    enable_catalog    = true
    enable_glossaries = true
    enable_quality    = true
    enable_profiling  = true

    # Lakes and zones
    lakes = [
      {
        lake_id      = "analytics-lake"
        display_name = "Analytics Data Lake"
        description  = "Central analytics lake for business intelligence"

        zones = [
          # RAW zone with GCS bucket
          {
            zone_id         = "raw-ingestion"
            type            = "RAW"
            display_name    = "Raw Data Ingestion"
            # ⚠️ Use FULL bucket name from builtin_gcs_v2.tf
            existing_bucket = "${LBU}-${ENV}-${STAGE}-${APPREF}-${AZ}-raw-data"
          },
          # CURATED zone with BigQuery dataset
          {
            zone_id          = "analytics-warehouse"
            type             = "CURATED"
            display_name     = "Analytics Warehouse"
            # ⚠️ Use dataset key from builtin_bigquery.tf
            existing_dataset = "analytics_warehouse"
          }
        ]
      }
    ]

    # Metadata catalog
    entry_groups = [
      {
        entry_group_id = "customer-data"
        display_name   = "Customer Data Assets"
        description    = "All customer-related data assets"
      }
    ]

    entry_types = [
      {
        entry_type_id = "data-asset"
        display_name  = "Data Asset"
        required_aspects = [
          { aspect_type = "data-quality-aspect" }
        ]
      }
    ]

    aspect_types = [
      {
        aspect_type_id = "data-quality-aspect"
        display_name   = "Data Quality Metadata"
        metadata_template = {
          name = "Data Quality"
          fields = [
            { field_id = "quality_score", display_name = "Quality Score", type = "DOUBLE", is_required = true }
          ]
        }
      }
    ]

    # Business glossaries
    glossaries = [
      {
        glossary_id  = "business-terms"
        display_name = "Business Glossary"
        terms = [
          { term_id = "customer", display_name = "Customer", description = "..." }
        ]
      }
    ]

    # Data quality scans
    quality_scans = [
      {
        scan_id      = "customer-quality"
        lake_id      = "analytics-lake"
        display_name = "Customer Data Quality"
        data_source  = "//bigquery.googleapis.com/projects/${PROJECT_ID}/datasets/analytics_warehouse/tables/customers"
        rules = [
          { rule_type = "NON_NULL", column = "customer_id", threshold = 1.0, dimension = "COMPLETENESS" },
          { rule_type = "UNIQUENESS", column = "customer_id", threshold = 1.0, dimension = "UNIQUENESS" }
        ]
        schedule = "0 2 * * *"
      }
    ]

    # Data profiling scans
    profiling_scans = [
      {
        scan_id      = "customer-profile"
        lake_id      = "analytics-lake"
        display_name = "Customer Data Profiling"
        data_source  = "//bigquery.googleapis.com/projects/${PROJECT_ID}/datasets/analytics_warehouse/tables/customers"
        schedule     = "0 3 * * 0"  # Weekly
      }
    ]
  }
}
```

**Naming Conventions - Critical:**

```hcl
# For GCS Buckets:
# In gcs_buckets_v2, you define SHORT name:
gcs_buckets_v2 = {
  "raw-data" : { ... }
}

# ISS Foundation creates FULL name:
# ${LBU}-${ENV}-${STAGE}-${APPREF}-${AZ}-raw-data

# In dataplex_lakes, use FULL name:
existing_bucket = "${LBU}-${ENV}-${STAGE}-${APPREF}-${AZ}-raw-data"

# For BigQuery Datasets:
# In bigquery_datasets, KEY is dataset ID:
bigquery_datasets = {
  "analytics_warehouse" : { ... }
}

# In dataplex_lakes, use EXACT same key:
existing_dataset = "analytics_warehouse"
```

---

### 3.5. Google Cloud Project Setup

**Project Structure:**

```
GCP Organization
└── ISS Foundation
    └── App-ref Project (e.g., pru-prod-runtime-analytics-az1)
        ├── GCS Buckets (builtin_gcs_v2.tf)
        ├── BigQuery Datasets (builtin_bigquery.tf)
        └── Dataplex Resources (builtin_dataplex.tf) ← NEW
            ├── Lakes
            ├── Zones
            ├── Assets (references to buckets/datasets)
            ├── Entry Groups
            ├── Glossaries (BigQuery tables)
            └── Data Scans
```

**Required APIs:**

```bash
gcloud services enable dataplex.googleapis.com \
  datacatalog.googleapis.com \
  bigquery.googleapis.com \
  storage-api.googleapis.com \
  --project=PROJECT_ID
```

**Service Accounts:**

1. **Google-Managed Dataplex SA** (automatic):
   ```
   service-{PROJECT_NUMBER}@gcp-sa-dataplex.iam.gserviceaccount.com
   ```
   - Created automatically when Dataplex API is enabled
   - Managed by Google (no keys to rotate)
   - Granted permissions by module: `roles/bigquery.dataViewer`, `roles/storage.objectViewer`

2. **Terraform SA** (for deployment):
   - Requires: `roles/dataplex.admin`, `roles/datacatalog.admin`, `roles/bigquery.dataEditor`
   - Recommend using Workload Identity (no long-term keys)

---

### 3.6. High Availability

**Dataplex is a regional service:**

- Runs on multiple zones within each region
- Single-zone failure does NOT impact availability
- Automatic failover within region
- No manual intervention required

**Considerations:**

- All Dataplex resources must be in same region
- Choose region matching your data location (e.g., `us-central1`, `europe-west1`)
- Multi-region support: Create separate lakes per region

---

### 3.7. Disaster Recovery

**Scenario**: Region-wide outage

**Impact**:
- Dataplex catalog unavailable during outage
- Underlying data (GCS, BigQuery) unaffected (stored redundantly)
- Quality/profiling scans paused during outage

**Recovery**:
- Dataplex service automatically recovers after region recovery
- Metadata catalog restored automatically
- Quality/profiling scans resume automatically
- No data loss (metadata is replicated within region)

**Infrastructure-as-Code Recovery**:
- All Dataplex resources defined in Terraform
- Can recreate resources in different region if needed
- Terraform state backed up to Cloud Storage (ISS Foundation pattern)

---

### 3.8. Dataplex Enablement Process

**Deployment Flow:**

```
1. Developer updates terraform.tfvars in app-ref repository
   ↓
2. Developer commits changes to Git (BitBucket)
   ↓
3. Developer triggers Jenkins pipeline
   ↓
4. Jenkins runs Terraform apply
   ↓
5. Terraform creates Dataplex resources in GCP
   ↓
6. Dataplex discovers and indexes assets automatically
   ↓
7. Quality/profiling scans start according to schedule
```

**Step-by-Step:**

1. **Update tfvars** in app-ref repository:
   ```bash
   cd gcp-foundation/tfvars/pru/prod/projects/analytics.tfvars
   # Add dataplex_lakes block
   ```

2. **Commit changes**:
   ```bash
   git add terraform.tfvars
   git commit -m "Add Dataplex catalog for analytics project"
   git push origin master
   ```

3. **Trigger Jenkins pipeline**:
   - Navigate to Jenkins
   - Select app-ref project pipeline
   - Click "Build with Parameters"
   - Select Terraform action: "apply"

4. **Verify deployment**:
   ```bash
   # Via gcloud
   gcloud dataplex lakes list --project=PROJECT_ID --location=REGION

   # Via GCP Console
   # Navigate to Dataplex → Lakes
   ```

---

## 4. Security Controls

This section provides a high-level overview of security controls and options for Dataplex service.

**For comprehensive security analysis, see [SECURITY_DISCOVERY.md](SECURITY_DISCOVERY.md)**

### 4.1. General Information

**Encryption:**

- **Data at Rest**:
  - GCS buckets: Encrypted by ISS Foundation (org-wide CMEK)
  - BigQuery datasets: Encrypted by ISS Foundation (org-wide CMEK)
  - Dataplex metadata: Encrypted by Google (Google-managed keys)
  - Scan results: Stored in BigQuery (org-wide CMEK)

- **Data in Transit**:
  - All API calls use TLS 1.2+
  - Traffic stays within Google private network
  - No public endpoints

**Access Control:**

- IAM roles for Dataplex resources
- Principle of least privilege
- Google-managed service account (no custom SAs)
- Lake-level IAM bindings (optional)

**Audit Logging:**

- Admin activity logs (always enabled)
- Data access logs (optional, recommended)
- 400-day retention (configurable)
- All operations tracked

---

### 4.2. Use CMEK for Encryption

**Important**: Dataplex module does NOT manage encryption keys.

**Encryption Handled by ISS Foundation:**

```
ISS Foundation manages:
├── Organization-level KMS keyring
├── Regional encryption keys
├── Key rotation (automatic, 90 days)
└── Key access controls

Dataplex module:
├── Does NOT create KMS keys
├── Does NOT configure encryption
└── Inherits encryption from underlying storage
```

**Verification:**

```bash
# Check bucket encryption
gsutil kms encryption gs://BUCKET_NAME

# Check BigQuery dataset encryption
bq show --format=prettyjson PROJECT:DATASET
```

---

### 4.3. User Access Control

**Predefined Roles:**

| Role | Purpose | Use Case |
|------|---------|----------|
| `roles/dataplex.admin` | Full control of Dataplex resources | Terraform SA (deployment) |
| `roles/dataplex.editor` | Create/update/delete resources | Data engineers |
| `roles/dataplex.viewer` | Read-only access | Data analysts, auditors |
| `roles/datacatalog.viewer` | Search catalog | All users |

**Recommended IAM Strategy:**

```hcl
# Lake-level access control
iam_bindings = [
  {
    lake_id = "analytics-lake"
    role    = "roles/dataplex.viewer"
    members = [
      "group:data-analysts@company.com",
      "group:data-scientists@company.com"
    ]
  }
]
```

**Security Note**: `roles/dataplex.viewer` grants read access to Dataplex metadata only, NOT underlying data. Underlying data access controlled by GCS/BigQuery IAM.

---

### 4.4. VPC Service Controls (Optional)

Dataplex is compatible with VPC Service Controls:

```
┌─────────────────────────────────────────┐
│ VPC-SC Perimeter                        │
│                                          │
│  Protected Project:                     │
│  • GCS Buckets                          │
│  • BigQuery Datasets                    │
│  • Dataplex Resources                   │
│                                          │
│  Access from outside: BLOCKED           │
└─────────────────────────────────────────┘
```

**Configuration**: VPC-SC configured at organization level (not by this module).

---

## 5. Development

### 5.1. Predefined Roles

**Terraform Service Account Permissions:**

| Role | Purpose |
|------|---------|
| `roles/dataplex.admin` | Create/update/delete Dataplex resources |
| `roles/datacatalog.admin` | Manage catalog entries |
| `roles/bigquery.dataEditor` | Create glossary tables and scan results |
| `roles/storage.objectViewer` | Read GCS bucket metadata (for asset discovery) |

**Recommended SA Configuration:**

```hcl
resource "google_service_account" "terraform_dataplex" {
  account_id   = "terraform-dataplex"
  display_name = "Terraform - Dataplex Deployment"
}

resource "google_project_iam_member" "terraform_roles" {
  for_each = toset([
    "roles/dataplex.admin",
    "roles/datacatalog.admin",
    "roles/bigquery.dataEditor",
    "roles/storage.objectViewer"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.terraform_dataplex.email}"
}
```

---

### 5.2. Runtime Service Account

**Google-Managed Dataplex SA:**

```
service-{PROJECT_NUMBER}@gcp-sa-dataplex.iam.gserviceaccount.com
```

**Lifecycle:**
- Created automatically when Dataplex API is enabled
- Managed by Google (cannot be deleted)
- No key rotation required (Google-managed)

**Permissions Granted by Module:**

```hcl
# For quality scans (read BigQuery data)
resource "google_project_iam_member" "dataplex_sa_bq" {
  project = var.project_id
  role    = "roles/bigquery.dataViewer"
  member  = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-dataplex.iam.gserviceaccount.com"
}

# For asset discovery (read GCS metadata)
resource "google_project_iam_member" "dataplex_sa_gcs" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-dataplex.iam.gserviceaccount.com"
}
```

---

### 5.3. Module Development Guidelines

**Terraform Best Practices:**

1. **Use `for_each` for dynamic resources** (no hardcoded limits)
2. **Validate inputs** with variable validation blocks
3. **Use `depends_on` sparingly** (prefer implicit dependencies)
4. **Output important resource IDs** for downstream modules
5. **Follow ISS Foundation naming conventions**

**Example Variable Validation:**

```hcl
variable "lakes" {
  type = list(object({
    lake_id = string
    zones = list(object({
      zone_id  = string
      type     = string  # RAW or CURATED
      existing_bucket  = optional(string)
      existing_dataset = optional(string)
    }))
  }))

  validation {
    condition = alltrue([
      for lake in var.lakes : alltrue([
        for zone in lake.zones : contains(["RAW", "CURATED"], zone.type)
      ])
    ])
    error_message = "Zone type must be either RAW or CURATED"
  }
}
```

---

## 6. Integration with Datastream

### 6.1. Use Case: CDC Pipeline with Cataloging

**Scenario**: Replicate data from Cloud SQL to BigQuery using Datastream, then catalog and govern with Dataplex.

**Architecture:**

```
┌─────────────┐      ┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│  Cloud SQL  │ ───▶ │ Datastream  │ ───▶ │  BigQuery   │ ───▶ │  Dataplex   │
│  (Source)   │      │    (CDC)    │      │(Destination)│      │ (Catalog)   │
└─────────────┘      └─────────────┘      └─────────────┘      └─────────────┘
   PostgreSQL          Replication         Dataset + Tables      Governance
```

**Step 1: Datastream Replication**

```hcl
# In terraform.tfvars (Datastream configuration)
datastream_streams = {
  "customer-cdc" = {
    source_connection_profile      = "cloudsql-postgres-source"
    destination_connection_profile = "bigquery-destination"
    postgres_source_config = {
      max_concurrent_backfill_tasks = 12
      publication      = "dataplex_publication"
      replication_slot = "dataplex_replication_slot"
    }
    # Datastream creates: customer_data dataset
  }
}
```

**Step 2: Dataplex Cataloging**

```hcl
# In terraform.tfvars (Dataplex configuration)
dataplex_lakes = {
  "customer-catalog" : {
    lakes = [{
      lake_id = "customer-lake"
      zones = [
        {
          zone_id          = "customer-data-curated"
          type             = "CURATED"
          # Reference dataset created by Datastream
          existing_dataset = "customer_data"
        }
      ]
    }]

    quality_scans = [{
      scan_id     = "customer-quality"
      lake_id     = "customer-lake"
      # Validate data replicated by Datastream
      data_source = "//bigquery.googleapis.com/projects/${PROJECT_ID}/datasets/customer_data/tables/customers"
      rules = [
        { rule_type = "NON_NULL", column = "customer_id", threshold = 1.0 },
        { rule_type = "UNIQUENESS", column = "customer_id", threshold = 1.0 }
      ]
      schedule = "0 2 * * *"
    }]
  }
}
```

**Benefits of Integration:**

- ✅ End-to-end data pipeline: Source → Replication → Cataloging → Governance
- ✅ Automated quality validation on replicated data
- ✅ Business glossaries for replicated tables
- ✅ Searchable catalog of CDC datasets
- ✅ Single ISS Foundation deployment (both Datastream and Dataplex)

---

### 6.2. Deployment Order

**Important**: Storage must exist before Dataplex can catalog it.

**Correct Order:**

1. **Deploy Storage** (first):
   ```bash
   # Includes builtin_gcs_v2.tf, builtin_bigquery.tf, builtin_datastream.tf
   terraform apply
   ```
   Result: GCS buckets, BigQuery datasets created (and populated by Datastream)

2. **Deploy Dataplex** (second):
   ```bash
   # Add builtin_dataplex.tf, reference existing storage
   terraform apply
   ```
   Result: Dataplex catalogs existing storage

**Module Dependency:**

```hcl
# In builtin_dataplex.tf
module "project_dataplex" {
  # ... configuration ...

  # Explicit dependency (if needed)
  depends_on = [
    module.project_gcs_buckets,
    module.project_bigquery_datasets,
    module.project_datastream
  ]
}
```

---

## 7. Monitoring and Operations

### 7.1. Monitoring Dashboards

**Cloud Monitoring Metrics:**

```yaml
Dataplex Metrics:
  - dataplex.googleapis.com/lake/asset_count
  - dataplex.googleapis.com/datascan/execution_count
  - dataplex.googleapis.com/datascan/execution_duration
  - dataplex.googleapis.com/datascan/execution_status

BigQuery Metrics (for scan results):
  - bigquery.googleapis.com/query/execution_times
  - bigquery.googleapis.com/storage/stored_bytes
```

**Recommended Alerts:**

```yaml
Alert 1: Quality Scan Failures
  Condition: datascan/execution_status = FAILED
  Duration: > 1 failure
  Notification: Email to data quality team

Alert 2: Asset Discovery Errors
  Condition: asset/discovery_status = ERROR
  Duration: > 5 minutes
  Notification: Email to platform team

Alert 3: API Quota Exhaustion
  Condition: API quota usage > 80%
  Duration: > 10 minutes
  Notification: Email to platform team
```

---

### 7.2. Operational Runbooks

**Runbook 1: Quality Scan Failure**

```yaml
Symptom: Quality scan failed
Diagnosis:
  1. Check scan execution logs:
     gcloud dataplex datascans describe SCAN_ID --location=REGION
  2. Check BigQuery table exists and has data
  3. Check Dataplex SA has permissions
Resolution:
  1. Fix underlying data issue (if data quality problem)
  2. Update scan configuration (if configuration issue)
  3. Manually trigger scan: gcloud dataplex datascans run SCAN_ID
```

**Runbook 2: Asset Not Discovered**

```yaml
Symptom: GCS bucket or BigQuery dataset not appearing in Dataplex
Diagnosis:
  1. Verify resource exists:
     gsutil ls gs://BUCKET_NAME
     bq ls --project_id=PROJECT
  2. Verify Dataplex asset configuration:
     gcloud dataplex assets describe ASSET_ID --location=REGION --lake=LAKE --zone=ZONE
  3. Check Dataplex SA permissions
Resolution:
  1. Update asset configuration (if incorrect resource reference)
  2. Grant Dataplex SA permissions (if permission issue)
  3. Wait for discovery cycle (up to 1 hour) or trigger manually
```

---

### 7.3. Terraform State Management

**State Backend Configuration:**

```hcl
# backend.tf
terraform {
  backend "gcs" {
    bucket = "{LBU}-{ENV}-terraform-state"
    prefix = "dataplex"
    encryption_key = "projects/{PROJECT}/locations/{REGION}/keyRings/{KEYRING}/cryptoKeys/{KEY}"
  }
}
```

**State Locking:**

- GCS backend provides automatic state locking
- Prevents concurrent Terraform runs
- Uses Cloud Storage object metadata for locking

**State Backup:**

```bash
# Automatic backup by GCS backend
# Previous state versions retained in GCS

# Manual backup before major changes
terraform state pull > terraform.tfstate.backup.$(date +%Y%m%d)
```

---

## 8. Testing and Validation

### 8.1. Pre-Deployment Validation

**Validation Checklist:**

```yaml
Infrastructure:
  ☐ GCS buckets exist (created by builtin_gcs_v2.tf)
  ☐ BigQuery datasets exist (created by builtin_bigquery.tf)
  ☐ Buckets encrypted with org-wide CMEK
  ☐ Datasets encrypted with org-wide CMEK

Terraform Configuration:
  ☐ terraform fmt -check (formatting)
  ☐ terraform validate (syntax)
  ☐ terraform plan (dry run, no errors)
  ☐ Variable values validated
  ☐ Naming conventions followed

IAM:
  ☐ Terraform SA has required permissions
  ☐ No overly permissive bindings
  ☐ Service account key secured (or using Workload Identity)

Compliance:
  ☐ Data residency requirements met (location parameter)
  ☐ Encryption requirements met (ISS Foundation CMEK)
  ☐ Audit logging enabled
```

---

### 8.2. Post-Deployment Validation

**Validation Commands:**

```bash
# 1. Verify lakes created
gcloud dataplex lakes list --project=PROJECT_ID --location=REGION

# 2. Verify zones created
gcloud dataplex zones list --project=PROJECT_ID --location=REGION --lake=LAKE_ID

# 3. Verify assets created
gcloud dataplex assets list --project=PROJECT_ID --location=REGION --lake=LAKE_ID --zone=ZONE_ID

# 4. Verify quality scans created
gcloud dataplex datascans list --project=PROJECT_ID --location=REGION

# 5. Verify scan execution
gcloud dataplex datascans describe SCAN_ID --location=REGION

# 6. Check scan results in BigQuery
bq query --use_legacy_sql=false \
  'SELECT * FROM `PROJECT.dataplex_quality_results.SCAN_ID` ORDER BY execution_time DESC LIMIT 10'

# 7. Verify IAM bindings
gcloud dataplex lakes get-iam-policy LAKE_ID --location=REGION

# 8. Verify encryption
gsutil kms encryption gs://BUCKET_NAME
bq show --format=prettyjson PROJECT:DATASET

# 9. Check audit logs
gcloud logging read 'resource.type="dataplex.googleapis.com/Lake"' --limit=10
```

---

### 8.3. Integration Testing

**Test Scenarios:**

```yaml
Test 1: Basic Cataloging
  Steps:
    1. Create GCS bucket via builtin_gcs_v2.tf
    2. Create Dataplex asset referencing bucket
    3. Verify asset discovery completes
  Expected: Asset status = ACTIVE

Test 2: Quality Scan Execution
  Steps:
    1. Create BigQuery dataset with test data
    2. Configure quality scan with NON_NULL rule
    3. Trigger scan execution
  Expected: Scan completes successfully, results in BigQuery

Test 3: Glossary Creation
  Steps:
    1. Configure business glossary with terms
    2. Deploy via Terraform
    3. Verify glossary table created in BigQuery
  Expected: Table exists with correct schema

Test 4: IAM Binding
  Steps:
    1. Configure lake-level IAM binding
    2. Deploy via Terraform
    3. Verify permissions granted
  Expected: User has dataplex.viewer role on lake

Test 5: Encryption Verification
  Steps:
    1. Create asset referencing encrypted bucket
    2. Verify asset inherits encryption
  Expected: Asset uses org-wide CMEK (inherited)
```

---

## 9. Migration and Rollback

### 9.1. Migration from Manual to IaC

**Scenario**: Existing Dataplex resources created manually in GCP Console. Need to migrate to Terraform management.

**Migration Steps:**

1. **Import existing resources**:
   ```bash
   # Import lake
   terraform import module.dataplex.google_dataplex_lake.lakes[\"lake-id\"] \
     projects/PROJECT_ID/locations/REGION/lakes/LAKE_ID

   # Import zone
   terraform import module.dataplex.google_dataplex_zone.zones[\"lake-id:zone-id\"] \
     projects/PROJECT_ID/locations/REGION/lakes/LAKE_ID/zones/ZONE_ID

   # Import asset
   terraform import module.dataplex.google_dataplex_asset.gcs_assets[\"lake-id:zone-id:asset-id\"] \
     projects/PROJECT_ID/locations/REGION/lakes/LAKE_ID/zones/ZONE_ID/assets/ASSET_ID
   ```

2. **Verify state**:
   ```bash
   terraform plan
   # Expected: No changes (resources already match configuration)
   ```

3. **Update documentation**:
   - Add note that resources now managed by Terraform
   - Update runbooks to use Terraform commands

---

### 9.2. Rollback Procedures

**Scenario**: Deployment failed or incorrect configuration applied.

**Rollback Options:**

**Option 1: Terraform Destroy (Clean Removal)**
```bash
# Destroy all Dataplex resources
terraform destroy -target=module.project_dataplex

# Note: Does NOT affect underlying storage (GCS, BigQuery)
```

**Option 2: Terraform State Rollback**
```bash
# Pull previous state from backup
gsutil cp gs://BUCKET/terraform.tfstate.backup ./terraform.tfstate

# Force unlock if needed
terraform force-unlock LOCK_ID

# Apply previous state
terraform apply
```

**Option 3: Selective Resource Destruction**
```bash
# Destroy specific resource
terraform destroy -target=module.project_dataplex.google_dataplex_datascan.quality_scans[\"scan-id\"]
```

**Critical**: Dataplex resources are **metadata only**. Destroying Dataplex resources does NOT affect underlying data (GCS buckets, BigQuery datasets remain intact).

---

## 10. Cost Optimization

### 10.1. Dataplex Pricing

**Cost Components:**

| Component | Pricing | Notes |
|-----------|---------|-------|
| **Managed Storage** | Free | Metadata storage (lakes, zones, assets) |
| **Metadata Management** | Free | Entry groups, types, aspect types |
| **Data Profiling** | $1.00 per 1 TB scanned | Statistical analysis |
| **Data Quality Scans** | $0.10 per 1 GB scanned | Validation rules |
| **BigQuery Storage** | Standard pricing | Glossary tables, scan results |
| **BigQuery Queries** | Standard pricing | Scan execution uses slots |

**Reference**: [Dataplex Pricing](https://cloud.google.com/dataplex/pricing)

---

### 10.2. Cost Optimization Strategies

**1. Optimize Scan Frequency**

```hcl
# Instead of hourly scans
schedule = "0 * * * *"  # Every hour = 720 scans/month

# Use daily scans for non-critical tables
schedule = "0 2 * * *"  # Daily = 30 scans/month (24x less cost)

# Use weekly scans for static tables
schedule = "0 2 * * 0"  # Weekly = 4 scans/month (180x less cost)
```

**2. Limit Scan Scope**

```hcl
# Scan specific columns (not all columns)
quality_scans = [{
  rules = [
    { rule_type = "NON_NULL", column = "customer_id" },  # Only scan critical columns
    # Don't scan every column in table
  ]
}]

# Use table filters (if supported)
profiling_scans = [{
  # Profile sample, not full table
  # (Check Dataplex docs for sampling support)
}]
```

**3. Monitor Costs**

```bash
# Create budget alert
gcloud billing budgets create \
  --billing-account=BILLING_ACCOUNT \
  --display-name="Dataplex Budget" \
  --budget-amount=1000 \
  --threshold-rule=percent=80 \
  --threshold-rule=percent=100

# Query costs
bq query --use_legacy_sql=false \
  'SELECT
     service.description,
     SUM(cost) as total_cost
   FROM `PROJECT.billing_export.gcp_billing_export_v1_XXXXX`
   WHERE service.description LIKE "%Dataplex%"
   GROUP BY service.description'
```

---

## 11. Appendices

### Appendix A: Complete tfvars Example

See [ISS_INTEGRATION.md](ISS_INTEGRATION.md) for complete examples.

---

### Appendix B: Terraform Module Variables

See [variables.tf](../variables.tf) for complete variable reference.

---

### Appendix C: Glossary

See [SECURITY_DISCOVERY.md](SECURITY_DISCOVERY.md) - Appendix B: Glossary

---

### Appendix D: References

**Official Documentation:**
- [Google Cloud Dataplex](https://cloud.google.com/dataplex)
- [Dataplex Universal Catalog](https://cloud.google.com/dataplex/docs)
- [Data Quality Overview](https://cloud.google.com/dataplex/docs/data-quality-overview)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)

**Related RFCs:**
- [RFC-44] Datastream for GCP (this document references Datastream integration)
- ISS Foundation Architecture (internal)

**Module Repository:**
- [GitHub - Dataplex Universal Catalog](https://github.com/Abhishek-Kraj/Dataplex-Universal-Catalog)
- Branch: `feature/iss-foundation` (catalog-only, ISS Foundation optimized)

---

### Appendix E: Change Log

| Date | Version | Change | Author |
|------|---------|--------|--------|
| 08 Jan 2025 | 1.0 | Initial RFC document | Data Platform Team |

---

**Document Status**: ☐ Draft | ☐ Under Review | ☐ Approved | ☐ Implemented

**Next Steps:**
1. Security team review and approval
2. Architecture team review
3. Compliance team review (if applicable)
4. Implementation planning
5. Testing and validation
6. Production deployment

---

**END OF DOCUMENT**

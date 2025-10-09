# [RFC] Dataplex Universal Catalog for ISS Foundation

> **Request for Comments** - Technical Specification for Dataplex Terraform Module

---

## Document Information

| Field | Value |
|-------|-------|
| **Author** | Data Platform Team |
| **Status** | 📝 Draft → Under Review → Approved → Implemented |
| **Current State** | **Draft** |
| **Version** | 1.0 |
| **Date** | January 8, 2025 |
| **Reviewers** | Security Team, Architecture Team, Compliance Team |

---

## Document History

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| Jan 8, 2025 | 1.0 | Initial RFC document | Data Platform Team |

---

## Approval Status

| Team | Reviewer | Status | Date | Comments |
|------|----------|--------|------|----------|
| **Security** | ___ | ⏳ Pending | ___ | ___ |
| **Architecture** | ___ | ⏳ Pending | ___ | ___ |
| **Compliance** | ___ | ⏳ Pending | ___ | ___ |

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Introduction](#2-introduction)
3. [Business Requirements](#3-business-requirements)
4. [Technical Architecture](#4-technical-architecture)
5. [ISS Foundation Integration](#5-iss-foundation-integration)
6. [Security & Compliance](#6-security--compliance)
7. [Implementation Plan](#7-implementation-plan)
8. [Operations & Monitoring](#8-operations--monitoring)
9. [Cost Analysis](#9-cost-analysis)
10. [Appendices](#10-appendices)

---

# 1. Executive Summary

## 1.1. Purpose

This RFC proposes the implementation of **GCP Dataplex Universal Catalog** as a Terraform module integrated with ISS (Infrastructure Self-Service) Foundation. The module provides data cataloging, governance, and quality monitoring capabilities for GCS buckets and BigQuery datasets.

## 1.2. Key Objectives

🎯 **Simplify Data Cataloging** - Automate metadata discovery and indexing for all data assets

🎯 **Enable Data Governance** - Implement quality monitoring, profiling, and business glossaries

🎯 **ISS Foundation Integration** - Seamless integration with existing ISS infrastructure patterns

🎯 **Infrastructure as Code** - 100% Terraform-managed, version-controlled deployment

## 1.3. Business Value

| Benefit | Impact | Stakeholder |
|---------|--------|-------------|
| **Centralized Data Discovery** | Data analysts can find data 10x faster | Data Analysts, Data Scientists |
| **Automated Quality Monitoring** | Early detection of data issues, reduce downstream errors | Data Engineers, Data Quality Team |
| **Compliance & Audit** | Complete audit trail, metadata for regulatory compliance | Compliance Officers, Auditors |
| **Reduced Operational Overhead** | Serverless, fully-managed (no infrastructure to maintain) | Platform Team, SRE |

## 1.4. Solution Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     ISS Foundation                               │
│                                                                  │
│  ┌──────────────────┐        ┌──────────────────┐              │
│  │ builtin_gcs_v2.tf│        │builtin_bigquery  │              │
│  │ Creates Buckets  │        │Creates Datasets  │              │
│  │ (with CMEK)      │        │(with CMEK)       │              │
│  └────────┬─────────┘        └────────┬─────────┘              │
│           │                           │                         │
│           └───────────┬───────────────┘                         │
│                       │                                         │
│           ┌───────────▼────────────────────────┐               │
│           │    builtin_dataplex.tf (NEW)       │               │
│           │                                     │               │
│           │  ✓ Catalogs existing resources     │               │
│           │  ✓ Data quality scans              │               │
│           │  ✓ Business glossaries             │               │
│           │  ✓ Metadata discovery              │               │
│           └────────────────────────────────────┘               │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**Key Design Principle**: 🚫 **Catalog-Only Pattern** - This module does NOT create storage. It only catalogs existing resources created by ISS Foundation.

---

# 2. Introduction

## 2.1. What is Dataplex?

**Google Cloud Dataplex** is a unified data management platform that helps you:

- 📊 **Organize** data into lakes, zones, and assets
- 🔍 **Discover** data through searchable metadata catalog
- ✅ **Govern** data with quality scans and profiling
- 📖 **Document** data with business glossaries
- 🔒 **Secure** data with IAM and encryption

**Service Type**: Serverless, fully-managed (no VMs, no infrastructure)

## 2.2. Why Do We Need This?

### Current State (Without Dataplex)

❌ Data scattered across hundreds of GCS buckets and BigQuery datasets
❌ No centralized catalog - analysts waste time searching for data
❌ No automated data quality monitoring - issues discovered too late
❌ No business glossary - inconsistent data definitions
❌ Manual metadata management - error-prone and time-consuming

### Future State (With Dataplex)

✅ **Centralized Catalog** - All data assets searchable in one place
✅ **Automated Discovery** - Metadata indexed automatically
✅ **Quality Monitoring** - Automated validation, early issue detection
✅ **Business Glossary** - Consistent terminology across organization
✅ **Infrastructure as Code** - Terraform-managed, version-controlled

## 2.3. Scope

### In Scope ✅

- Cataloging existing GCS buckets and BigQuery datasets
- Data quality scans (5 rule types: NON_NULL, UNIQUENESS, REGEX, RANGE, SET_MEMBERSHIP)
- Data profiling scans (statistical analysis)
- Business glossaries (terms and definitions)
- Metadata catalog (entry groups, entry types, aspect types)
- Integration with ISS Foundation (`builtin_gcs_v2.tf`, `builtin_bigquery.tf`)
- Integration with Datastream (catalog CDC-replicated datasets)

### Out of Scope ❌

- Creating GCS buckets (use `builtin_gcs_v2.tf`)
- Creating BigQuery datasets (use `builtin_bigquery.tf`)
- Managing encryption keys (ISS Foundation handles org-wide CMEK)
- Creating custom service accounts (uses Google-managed SA)
- Spark/Dataproc tasks (`enable_process = false`)
- Data ingestion or ETL pipelines (use Datastream, Dataflow)
- Network configuration (Dataplex is serverless)

## 2.4. Key Terms & Definitions

| Term | Simple Explanation | Example |
|------|-------------------|---------|
| **Lake** | Top-level folder for organizing data | "Customer Data Lake", "Financial Data Lake" |
| **Zone** | Subdivision of a lake (RAW or CURATED) | RAW = raw files, CURATED = clean tables |
| **Asset** | Link to actual data (bucket or dataset) | gs://my-bucket or BigQuery dataset |
| **Entry Group** | Category for organizing metadata | "Customer Data", "Product Catalog" |
| **Quality Scan** | Automated data validation | Check for missing values, duplicates |
| **Profiling Scan** | Statistical analysis | Min/max values, null percentages |
| **Glossary** | Business vocabulary | "Customer = person who buys products" |

---

# 3. Business Requirements

## 3.1. User Stories

### 👨‍💻 Developer Persona

**As a Developer**, I want to:
- Use ISS Foundation framework to deploy Dataplex with Terraform
- Catalog existing GCS buckets and BigQuery datasets without recreating them
- Have all configuration in version-controlled tfvars files

**Acceptance Criteria**:
- ✅ Add `dataplex_lakes` block to terraform.tfvars
- ✅ Run Jenkins pipeline (standard ISS Foundation workflow)
- ✅ Dataplex resources created automatically

---

### 👨‍🔧 Data Engineer Persona

**As a Data Engineer**, I want to:
- Organize data into logical lakes and zones (RAW vs CURATED)
- Separate landing data (RAW) from processed data (CURATED)
- Ensure all data assets are cataloged for discoverability

**Acceptance Criteria**:
- ✅ Create multiple lakes for different domains
- ✅ Create RAW zones for ingestion, CURATED zones for processed data
- ✅ Automatic metadata discovery (no manual work)

---

### 👩‍💼 Data Analyst Persona

**As a Data Analyst**, I want to:
- Search and discover data assets across the organization
- Find business definitions for data terms
- Understand data quality and profiling statistics

**Acceptance Criteria**:
- ✅ Searchable data catalog via GCP Console
- ✅ Business glossary with term definitions
- ✅ Quality scores visible for all datasets

---

### 🔍 Data Quality Engineer Persona

**As a Data Quality Engineer**, I want to:
- Configure automated quality scans to validate data
- Monitor quality scan results over time
- Get alerts when data quality issues are detected

**Acceptance Criteria**:
- ✅ 5 rule types supported (NON_NULL, UNIQUENESS, REGEX, RANGE, SET_MEMBERSHIP)
- ✅ Scheduled execution (daily/weekly/custom cron)
- ✅ Results stored in BigQuery for analysis

---

### 📋 Compliance Officer Persona

**As a Compliance Officer**, I want to:
- Ensure all data assets are properly cataloged
- Have metadata for audit and regulatory compliance
- Track who accessed what data (audit logs)

**Acceptance Criteria**:
- ✅ Complete catalog of all GCS buckets and BigQuery datasets
- ✅ Metadata includes data classification, owner, sensitivity
- ✅ Audit logs for all Dataplex operations

---

## 3.2. Use Cases

### Use Case 1: Data Cataloging and Organization

**Scenario**: A data engineering team manages 50+ GCS buckets and 30+ BigQuery datasets created by ISS Foundation. They need to organize and catalog these for easy discovery.

**Current Problem**:
- Analysts waste hours searching for the right dataset
- No documentation on what each bucket/dataset contains
- No way to search across all data assets

**Solution with Dataplex**:

```
Step 1: Create Dataplex Lake
└── Analytics Lake
    ├── RAW Zone (Ingestion)
    │   ├── Asset → gs://pru-prod-runtime-analytics-az1-raw-data
    │   └── Asset → gs://pru-prod-runtime-analytics-az1-logs
    └── CURATED Zone (Processed)
        ├── Asset → BigQuery Dataset: analytics_warehouse
        └── Asset → BigQuery Dataset: customer_360

Step 2: Dataplex Automatically:
- Discovers metadata (schema, table names, file formats)
- Indexes data for search
- Makes it searchable in GCP Console

Step 3: Analysts Search:
- Search: "customer email"
- Results: Shows all tables/files with customer email
- Click to see schema, sample data, quality scores
```

**Benefits**:
- ⏱️ **10x faster** data discovery
- 🔍 **Searchable** catalog (like Google Search for data)
- 📈 **Automatic** metadata indexing

---

### Use Case 2: Data Quality Monitoring

**Scenario**: Customer data in BigQuery is used by downstream analytics. Bad data (nulls, duplicates) causes report errors.

**Current Problem**:
- Data quality issues discovered after reports fail
- Manual SQL queries to check data quality
- No automated monitoring

**Solution with Dataplex**:

```hcl
# Configure quality scan
quality_scans = [{
  scan_id     = "customer-quality"
  data_source = "//bigquery.googleapis.com/projects/PROJECT/datasets/analytics/tables/customers"

  rules = [
    # Check for missing customer IDs
    {
      rule_type  = "NON_NULL"
      column     = "customer_id"
      threshold  = 1.0          # 100% must be non-null
      dimension  = "COMPLETENESS"
    },
    # Check for duplicate customer IDs
    {
      rule_type  = "UNIQUENESS"
      column     = "customer_id"
      threshold  = 1.0          # 100% must be unique
      dimension  = "UNIQUENESS"
    },
    # Validate email format
    {
      rule_type  = "REGEX"
      column     = "email"
      pattern    = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
      threshold  = 0.95         # 95% must match pattern
      dimension  = "VALIDITY"
    },
    # Check age is realistic
    {
      rule_type  = "RANGE"
      column     = "age"
      min_value  = 18
      max_value  = 120
      threshold  = 0.99         # 99% must be in range
      dimension  = "VALIDITY"
    },
    # Check status is in allowed list
    {
      rule_type      = "SET_MEMBERSHIP"
      column         = "status"
      allowed_values = ["active", "inactive", "pending"]
      threshold      = 1.0      # 100% must be in list
      dimension      = "VALIDITY"
    }
  ]

  schedule = "0 2 * * *"  # Run daily at 2 AM
}]
```

**What Happens**:
1. Scan runs automatically every day at 2 AM
2. Validates all rules against BigQuery table
3. Results stored in BigQuery (pass/fail, percentage, failed rows count)
4. Alerts if quality falls below threshold

**Benefits**:
- 🚨 **Early detection** of data quality issues
- 📊 **Trend analysis** (quality over time)
- ⚡ **Automated** (no manual SQL queries)

---

### Use Case 3: Business Glossary for Data Governance

**Scenario**: Different teams use different definitions for "customer", "revenue", "churn". This causes confusion and incorrect analysis.

**Current Problem**:
- No central source of truth for business terms
- Teams interpret data differently
- Documentation scattered in wikis, Excel files

**Solution with Dataplex**:

```hcl
glossaries = [{
  glossary_id  = "insurance-business-terms"
  display_name = "Insurance Business Glossary"
  description  = "Standard definitions for insurance data"

  terms = [
    {
      term_id      = "customer"
      display_name = "Customer"
      description  = "An individual or organization that has purchased at least one insurance policy from us. Excludes prospects (leads who haven't purchased yet)."
    },
    {
      term_id      = "policy"
      display_name = "Insurance Policy"
      description  = "A legally binding contract between the insurer (us) and policyholder (customer) that provides coverage for specified risks in exchange for premium payments."
    },
    {
      term_id      = "claim"
      display_name = "Insurance Claim"
      description  = "A formal request by a policyholder to the insurance company for coverage or compensation for a covered loss or policy event."
    },
    {
      term_id      = "premium"
      display_name = "Insurance Premium"
      description  = "The amount of money charged by the insurer for providing insurance coverage, typically paid monthly, quarterly, or annually."
    },
    {
      term_id      = "churn_rate"
      display_name = "Customer Churn Rate"
      description  = "Percentage of customers who cancel their policies within a given time period. Calculated as: (Policies Cancelled / Total Active Policies) × 100."
    }
  ]
}]
```

**What Happens**:
1. Terms stored in BigQuery table (searchable)
2. Available in Data Catalog search
3. Linked to relevant data assets
4. Everyone uses same definitions

**Benefits**:
- 📖 **Single source of truth** for business terms
- 🤝 **Consistent** understanding across teams
- 🔍 **Searchable** via Data Catalog

---

### Use Case 4: Integration with Datastream CDC Pipeline

**Scenario**: Data replicated from Cloud SQL (PostgreSQL) to BigQuery using Datastream. Need to catalog and govern the replicated data.

**Architecture**:

```
┌─────────────┐   CDC    ┌─────────────┐  Catalog  ┌─────────────┐
│  Cloud SQL  │ ──────▶  │ Datastream  │ ────────▶ │  BigQuery   │
│ (PostgreSQL)│          │ Replication │           │  Dataset    │
└─────────────┘          └─────────────┘           └──────┬──────┘
     Source                                                │
                                                           │
                                                   ┌───────▼──────┐
                                                   │   Dataplex   │
                                                   │   Catalog    │
                                                   │              │
                                                   │ • Quality    │
                                                   │ • Glossary   │
                                                   │ • Search     │
                                                   └──────────────┘
```

**Configuration**:

```hcl
# Step 1: Datastream replicates data (separate module)
# Cloud SQL → BigQuery dataset: customer_data

# Step 2: Dataplex catalogs the dataset
dataplex_lakes = {
  "customer-catalog" : {
    lakes = [{
      lake_id = "customer-lake"
      zones = [{
        zone_id          = "customer-data-curated"
        type             = "CURATED"
        existing_dataset = "customer_data"  # Created by Datastream
      }]
    }]

    # Step 3: Validate replicated data quality
    quality_scans = [{
      scan_id     = "customer-cdc-quality"
      data_source = "//bigquery.googleapis.com/projects/PROJECT/datasets/customer_data/tables/customers"
      rules = [
        { rule_type = "NON_NULL", column = "customer_id", threshold = 1.0 },
        { rule_type = "UNIQUENESS", column = "customer_id", threshold = 1.0 }
      ]
      schedule = "0 */4 * * *"  # Every 4 hours (more frequent for CDC data)
    }]
  }
}
```

**Benefits**:
- 🔄 **End-to-end pipeline**: Source → CDC → Catalog → Governance
- ✅ **Validate replicated data** quality automatically
- 📊 **Monitor CDC lag** and data freshness

---

## 3.2.5. Google Cloud Official Use Cases & Features

This section incorporates the official Google Cloud Dataplex use cases and capabilities to provide a complete picture of what Dataplex Universal Catalog can do.

### Official Use Cases

Dataplex Universal Catalog is designed to address the following use cases:

#### 1. Discover and Understand Your Data

**What it does**: Dataplex Universal Catalog provides visibility over your data resources across the organization. It lets you find relevant resources for data consumption needs.

**How it works**:
- Automatically discovers and catalogs data across GCS, BigQuery, Spanner, Cloud SQL, Pub/Sub, Dataform, and more
- Provides a unified view of all data assets in one place
- Enables search and discovery through natural language queries
- Shows metadata, schema, and lineage information

**ISS Foundation Example**:
```hcl
# Catalog all ISS Foundation resources automatically
dataplex_lakes = {
  "organization-catalog" : {
    lakes = [{
      lake_id     = "enterprise-data-lake"
      description = "Organization-wide data catalog"
      zones = [
        {
          zone_id         = "gcs-raw-zone"
          type            = "RAW"
          existing_bucket = "pru-prod-runtime-analytics-az1-raw-data"
        },
        {
          zone_id          = "bigquery-curated-zone"
          type             = "CURATED"
          existing_dataset = "analytics_warehouse"
        }
      ]
    }]
  }
}
```

---

#### 2. Enable Data Governance and Data Management

**What it does**: Dataplex Universal Catalog supplies metadata that can inform and power your data governance and data management capabilities.

**Key Capabilities**:
- **Metadata Management**: Automatically harvested metadata from Google Cloud resources
- **Data Classification**: Tag data with sensitivity levels (PII, Confidential, Public)
- **Access Control**: Integrate with IAM for fine-grained permissions
- **Audit Trail**: Complete logs of who accessed what data and when

**ISS Foundation Example**:
```hcl
# Add metadata tags for governance
dataplex_lakes = {
  "governed-catalog" : {
    lakes = [{
      lake_id = "compliance-lake"
      labels = {
        compliance  = "sox"
        data_class  = "confidential"
        department  = "finance"
      }
      zones = [{
        zone_id          = "customer-pii"
        type             = "CURATED"
        existing_dataset = "customer_data"
        # Attach business glossary
      }]
    }]

    # Define business glossary
    glossaries = [{
      glossary_id = "financial-terms"
      terms = [
        {
          name        = "Revenue"
          definition  = "Total income generated from sales before expenses"
          classification = "Financial Metric"
        },
        {
          name        = "Customer"
          definition  = "Individual or organization that purchases products/services"
          classification = "Business Entity"
        }
      ]
    }]
  }
}
```

---

#### 3. Create a Central Data Catalog

**What it does**: Dataplex Universal Catalog stores and provides access to metadata that is automatically harvested from your Google Cloud resources. You can integrate your own metadata from non-Google Cloud systems.

**Integration Points**:
- Google Cloud native resources (BigQuery, GCS, etc.)
- Third-party metadata via custom entry groups
- Business metadata (glossaries, annotations)
- Technical metadata (schema, statistics)

**Architecture**:

```
┌─────────────────────────────────────────────────────────────────┐
│                  Integrated Analytics Experience                 │
│                  Curate | Integrate | Analyze                    │
└───────────────────────────┬─────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
┌───────▼────────┐  ┌──────▼──────┐  ┌─────────▼────────┐
│ Data           │  │ Data Lakes  │  │  Data Marts      │
│ Warehouses     │  │             │  │                  │
│ (BigQuery)     │  │ (GCS)       │  │  (BigQuery)      │
└───────┬────────┘  └──────┬──────┘  └─────────┬────────┘
        │                   │                   │
        └───────────────────┼───────────────────┘
                            │
        ┌───────────────────▼───────────────────────────┐
        │      Unified Data Management                   │
        │  Metadata | Intelligence | Lifecycle |         │
        │  Governance | Security                         │
        │                                                │
        │         Dataplex Universal Catalog             │
        └────────────────────────────────────────────────┘
```

**ISS Foundation Example**:
```hcl
# Create unified catalog with entry groups
dataplex_lakes = {
  "central-catalog" : {
    lakes = [{
      lake_id     = "enterprise-catalog"
      description = "Central metadata repository"
      zones = [
        { zone_id = "raw-zone", type = "RAW", existing_bucket = "data-raw" },
        { zone_id = "curated-zone", type = "CURATED", existing_dataset = "data_warehouse" }
      ]
    }]

    # Organize metadata into entry groups
    entry_groups = [{
      entry_group_id = "customer-data"
      description    = "All customer-related data assets"
      entries = [
        {
          entry_id    = "customer-profile"
          entry_type  = "customer_table"
          description = "Customer profile with PII data"
        },
        {
          entry_id    = "customer-transactions"
          entry_type  = "transaction_table"
          description = "Customer purchase history"
        }
      ]
    }]
  }
}
```

---

### Dataplex Universal Catalog Features

The module supports all core Dataplex features as documented by Google Cloud:

#### 1. Metadata Cataloging

**Description**: Retrieve metadata for Google Cloud resources (BigQuery, Cloud SQL, Spanner, Vertex AI, Pub/Sub, Dataform, Dataplex Metastore) and third-party resources for an instant data catalog.

**Supported Resources**:
- ✅ BigQuery (tables, views, datasets)
- ✅ Cloud Storage (buckets, objects)
- ✅ Cloud SQL (databases, tables)
- ✅ Spanner (databases, tables)
- ✅ Vertex AI (models, datasets)
- ✅ Pub/Sub (topics, subscriptions)
- ✅ Dataform (repositories, workflows)
- ✅ Dataplex Metastore (catalogs)

**ISS Foundation Integration**: Automatically catalogs resources created by `builtin_gcs_v2.tf` and `builtin_bigquery.tf`.

---

#### 2. Data Discovery

**Description**: Scan for structured and unstructured data in Cloud Storage buckets to extract and catalog their metadata.

**Capabilities**:
- Automatic schema detection for CSV, JSON, Avro, Parquet, ORC files
- File format identification
- Metadata extraction (file size, row count, column types)
- Incremental scanning (only new/modified files)

**ISS Foundation Example**:
```hcl
# Enable discovery scans for raw data zone
dataplex_lakes = {
  "discovery-catalog" : {
    lakes = [{
      lake_id = "raw-data-lake"
      zones = [{
        zone_id         = "raw-files"
        type            = "RAW"
        existing_bucket = "pru-prod-runtime-analytics-az1-raw-data"

        # Dataplex automatically discovers:
        # - CSV files → extracts schema
        # - JSON files → infers structure
        # - Parquet files → reads embedded schema
      }]
    }]
  }
}
```

---

#### 3. Data Insights

**Description**: Use AI to generate natural language questions about your data, to uncover patterns, assess data quality, and perform statistical analyses.

**Capabilities**:
- Natural language queries (e.g., "Show me tables with customer email")
- AI-powered pattern detection
- Statistical analysis (min, max, avg, percentiles)
- Null count and unique value analysis

**Example Queries**:
```
• "Find all tables with PII data"
• "Show me datasets modified in the last 7 days"
• "What tables have the most null values?"
• "Which datasets are largest by size?"
```

---

#### 4. Data Profiling

**Description**: Identify, classify, and review common characteristics of column values (typical data values, data distribution, null counts, etc.) in BigQuery tables.

**What it measures**:
- Data distribution (min, max, mean, median, percentiles)
- Null counts and null percentages
- Unique value counts
- String length statistics
- Numeric range and distribution

**ISS Foundation Example**:
```hcl
# Profile customer data for statistical insights
dataplex_lakes = {
  "profiled-catalog" : {
    profiling_scans = [{
      scan_id     = "customer-profile-scan"
      data_source = "//bigquery.googleapis.com/projects/PROJECT/datasets/customer_data/tables/customers"
      schedule    = "0 0 * * 0"  # Weekly on Sunday

      # Results show:
      # - customer_id: 100% non-null, 1M unique values
      # - email: 98% non-null, 15% duplicates
      # - age: min=18, max=95, mean=42.5, p50=41
    }]
  }
}
```

---

#### 5. Data Quality

**Description**: Define and measure the quality of the data in your BigQuery tables, by validating data against organizational policies and logging alerts if data doesn't meet quality criteria.

**Supported Rules**:
- **NON_NULL**: Column must not have null values
- **UNIQUENESS**: Column must have unique values (no duplicates)
- **REGEX**: String must match regex pattern (e.g., email format)
- **RANGE**: Numeric value must be within min/max range
- **SET_MEMBERSHIP**: Value must be in predefined set (e.g., status IN ['active', 'pending', 'closed'])

**ISS Foundation Example**:
```hcl
# Enforce data quality rules
dataplex_lakes = {
  "quality-catalog" : {
    quality_scans = [{
      scan_id     = "customer-quality-scan"
      data_source = "//bigquery.googleapis.com/projects/PROJECT/datasets/customer_data/tables/customers"
      schedule    = "0 */6 * * *"  # Every 6 hours

      rules = [
        {
          rule_type = "NON_NULL"
          column    = "customer_id"
          threshold = 1.0  # 100% must be non-null
        },
        {
          rule_type = "UNIQUENESS"
          column    = "email"
          threshold = 0.99  # 99% must be unique
        },
        {
          rule_type = "REGEX"
          column    = "email"
          regex     = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
          threshold = 0.95
        },
        {
          rule_type = "RANGE"
          column    = "age"
          min_value = 18
          max_value = 120
          threshold = 1.0
        },
        {
          rule_type      = "SET_MEMBERSHIP"
          column         = "status"
          allowed_values = ["active", "pending", "suspended", "closed"]
          threshold      = 1.0
        }
      ]
    }]
  }
}
```

---

#### 6. Business Glossary

**Description**: Manage business-related terminology and definitions across your organization and attach terms to table columns to promote a consistent understanding of data usage.

**Capabilities**:
- Define business terms with clear definitions
- Attach terms to BigQuery columns
- Classify terms by category
- Search and discover business vocabulary
- Enforce consistent terminology

**ISS Foundation Example**:
```hcl
# Create business glossary for data governance
dataplex_lakes = {
  "governed-catalog" : {
    glossaries = [{
      glossary_id = "business-terms"
      description = "Enterprise-wide business vocabulary"

      terms = [
        {
          name           = "Customer"
          definition     = "An individual or organization that purchases products or services from the company"
          classification = "Business Entity"
        },
        {
          name           = "Revenue"
          definition     = "Total income generated from sales of goods or services before deducting expenses"
          classification = "Financial Metric"
        },
        {
          name           = "Churn"
          definition     = "The percentage of customers who stop using the product during a given time period"
          classification = "Business Metric"
        },
        {
          name           = "PII"
          definition     = "Personally Identifiable Information - data that can identify a specific individual"
          classification = "Data Classification"
        },
        {
          name           = "ARR"
          definition     = "Annual Recurring Revenue - predictable revenue expected over the next 12 months"
          classification = "Financial Metric"
        }
      ]
    }]
  }
}
```

---

#### 7. Data Lineage

**Description**: Track how data moves through your systems: where it comes from, where it is passed to, and what transformations are applied to it.

**Capabilities**:
- Automatic lineage for BigQuery (queries, views, scheduled queries)
- Manual lineage via API for custom transformations
- Visual lineage graphs in GCP Console
- Impact analysis (upstream/downstream dependencies)

**Example Lineage Flow**:
```
Cloud SQL (PostgreSQL)
    │
    │ (Datastream CDC)
    ▼
BigQuery Raw Dataset
    │
    │ (dbt transformation)
    ▼
BigQuery Curated Dataset
    │
    │ (Scheduled query)
    ▼
BigQuery Analytics Views
    │
    │ (Looker dashboard)
    ▼
Business Reports
```

**ISS Foundation**: Lineage is automatically captured for all BigQuery operations. No configuration needed.

---

### Visual Overview: Dataplex Architecture

The following diagram shows how Dataplex integrates with ISS Foundation and existing data infrastructure:

```
┌─────────────────────────────────────────────────────────────────┐
│                     ISS Foundation (Level 3 Runtime)             │
│                                                                  │
│  ┌──────────────────┐        ┌──────────────────┐              │
│  │ builtin_gcs_v2.tf│        │builtin_bigquery  │              │
│  │                  │        │                  │              │
│  │ • Creates Buckets│        │ • Creates        │              │
│  │ • Applies CMEK   │        │   Datasets       │              │
│  │ • Sets IAM       │        │ • Applies CMEK   │              │
│  │                  │        │ • Sets IAM       │              │
│  └────────┬─────────┘        └────────┬─────────┘              │
│           │                           │                         │
│           │  References existing      │                         │
│           │  resources (no recreation)│                         │
│           │                           │                         │
│           └───────────┬───────────────┘                         │
│                       │                                         │
│           ┌───────────▼────────────────────────┐               │
│           │    builtin_dataplex.tf (NEW)       │               │
│           │                                     │               │
│           │  ✓ Lakes & Zones (organization)    │               │
│           │  ✓ Assets (catalog existing data)  │               │
│           │  ✓ Quality Scans (data validation) │               │
│           │  ✓ Profiling Scans (statistics)    │               │
│           │  ✓ Glossaries (business terms)     │               │
│           │  ✓ Entry Groups (metadata org)     │               │
│           │                                     │               │
│           │  Security via ISS Foundation:      │               │
│           │  • Google-managed service account  │               │
│           │  • Org-wide CMEK (automatic)       │               │
│           │  • No custom IAM                   │               │
│           └────────────────────────────────────┘               │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
                            │
                            │ Metadata flows to
                            ▼
        ┌────────────────────────────────────┐
        │    GCP Console - Data Catalog UI   │
        │                                    │
        │  • Search for datasets/tables      │
        │  • View quality scores             │
        │  • See lineage graphs              │
        │  • Browse business glossary        │
        │  • Check profiling statistics      │
        └────────────────────────────────────┘
```

---

### Summary: Why Use Dataplex Universal Catalog?

| Use Case | Without Dataplex | With Dataplex |
|----------|------------------|---------------|
| **Finding Data** | Manual search through folders, ask teammates | Search like Google: "customer email" → instant results |
| **Data Quality** | Discover issues after reports fail | Automated scans catch issues early, alert on failures |
| **Business Terms** | Each team uses different definitions | Central glossary ensures consistent understanding |
| **Compliance** | Manual tracking of PII and sensitive data | Automatic classification, complete audit trail |
| **Metadata** | Scattered in documentation, tribal knowledge | Centralized, searchable, always up-to-date |
| **Integration** | Build custom solutions | Native integration with BigQuery, GCS, etc. |

---

## 3.3. Functional Requirements

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| **FR-1** | Terraform-based deployment (100% IaC) | 🔴 Critical | ✅ Implemented |
| **FR-2** | Catalog existing GCS buckets (no creation) | 🔴 Critical | ✅ Implemented |
| **FR-3** | Catalog existing BigQuery datasets (no creation) | 🔴 Critical | ✅ Implemented |
| **FR-4** | Support RAW zones (any data format) | 🔴 Critical | ✅ Implemented |
| **FR-5** | Support CURATED zones (structured data only) | 🔴 Critical | ✅ Implemented |
| **FR-6** | Data quality scans (5 rule types) | 🔴 Critical | ✅ Implemented |
| **FR-7** | Data profiling scans (statistical analysis) | 🟡 High | ✅ Implemented |
| **FR-8** | Business glossaries (terms and definitions) | 🟡 High | ✅ Implemented |
| **FR-9** | Metadata catalog (entry groups, types, aspects) | 🟡 High | ✅ Implemented |
| **FR-10** | ISS Foundation integration | 🔴 Critical | ✅ Implemented |
| **FR-11** | Org-wide CMEK encryption (via ISS Foundation) | 🔴 Critical | ✅ Implemented |
| **FR-12** | Google-managed service account (no custom SAs) | 🔴 Critical | ✅ Implemented |
| **FR-13** | Scheduled quality scans (cron) | 🟡 High | ✅ Implemented |
| **FR-14** | IAM bindings at lake level | 🟢 Medium | ✅ Implemented |
| **FR-15** | Cloud Audit Logs integration | 🔴 Critical | ✅ Automatic |

---

## 3.4. Non-Functional Requirements

| ID | Requirement | Target | Status |
|----|-------------|--------|--------|
| **NFR-1** | Deployment time | < 5 minutes | ✅ Met |
| **NFR-2** | Regional availability | All GCP regions | ✅ Met |
| **NFR-3** | Serverless (no infrastructure to manage) | 100% serverless | ✅ Met |
| **NFR-4** | Encryption (data at rest) | CMEK (ISS Foundation) | ✅ Met |
| **NFR-5** | Encryption (data in transit) | TLS 1.2+ | ✅ Met |
| **NFR-6** | High availability | 99.9% SLA | ✅ Met (Google SLA) |
| **NFR-7** | Disaster recovery | Regional redundancy | ✅ Met |
| **NFR-8** | Audit logging | 100% of operations | ✅ Met |
| **NFR-9** | Cost predictability | Pay-per-use (no fixed cost) | ✅ Met |
| **NFR-10** | Documentation | Complete README + guides | ✅ Met |

---

## 3.5. Constraints

| ID | Constraint | Impact | Mitigation |
|----|-----------|--------|------------|
| **CON-1** | Catalog-only pattern (no storage creation) | Module cannot create buckets/datasets | ✅ Use `builtin_gcs_v2.tf` / `builtin_bigquery.tf` |
| **CON-2** | Regional service (all resources in same region) | Cannot span multiple regions | ⚠️ Create separate lakes per region |
| **CON-3** | Quality scans only on BigQuery tables | Cannot scan GCS files directly | ⚠️ Load data to BigQuery for scanning |
| **CON-4** | CURATED zones require structured data | RAW formats not allowed in CURATED | ✅ Use RAW zones for unstructured data |
| **CON-5** | Same-project asset cataloging only | Cannot catalog cross-project resources | ⚠️ Deploy module in each project |
| **CON-6** | No encryption key management | Module cannot create/rotate keys | ✅ ISS Foundation handles CMEK |
| **CON-7** | Google-managed SA only | No custom service accounts | ✅ Sufficient for cataloging use case |
| **CON-8** | Glossaries stored as BigQuery tables | Native glossaries not in Terraform yet | ⚠️ Workaround using BQ tables |

---

## 3.6. Assumptions

✅ GCP Organization and billing account exist
✅ ISS Foundation is deployed and operational
✅ GCS buckets and BigQuery datasets already exist (created by ISS Foundation)
✅ Org-wide CMEK keys are configured at organization level
✅ Terraform service account has required permissions
✅ Network connectivity not needed (Dataplex is serverless)
✅ Jenkins CI/CD pipeline is available for deployment

---

# 4. Technical Architecture

## 4.1. Architecture Overview

### High-Level Architecture

```
┌───────────────────────────────────────────────────────────────────────┐
│                  GCP Organization (ISS Foundation)                     │
│                                                                        │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │ Org-wide CMEK Encryption                                      │   │
│  │ • KMS Keyring per region                                      │   │
│  │ • Automatic key rotation (90 days)                            │   │
│  │ • HSM protection level                                        │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                        │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │ App-ref Project: pru-prod-runtime-analytics-az1               │   │
│  │                                                                │   │
│  │  ┌────────────────────────────────────────────────────────┐  │   │
│  │  │ Level 3 Runtime - builtin_gcs_v2.tf                    │  │   │
│  │  │                                                          │  │   │
│  │  │ Creates GCS Buckets:                                    │  │   │
│  │  │ • pru-prod-runtime-analytics-az1-raw-data              │  │   │
│  │  │ • pru-prod-runtime-analytics-az1-curated-data          │  │   │
│  │  │                                                          │  │   │
│  │  │ Features:                                                │  │   │
│  │  │ ✓ Encrypted with org-wide CMEK                          │  │   │
│  │  │ ✓ Uniform bucket-level access                           │  │   │
│  │  │ ✓ Versioning enabled                                    │  │   │
│  │  └────────────────────────────────────────────────────────┘  │   │
│  │                                                                │   │
│  │  ┌────────────────────────────────────────────────────────┐  │   │
│  │  │ Level 3 Runtime - builtin_bigquery.tf                  │  │   │
│  │  │                                                          │  │   │
│  │  │ Creates BigQuery Datasets:                              │  │   │
│  │  │ • analytics_warehouse                                   │  │   │
│  │  │ • customer_360                                          │  │   │
│  │  │                                                          │  │   │
│  │  │ Features:                                                │  │   │
│  │  │ ✓ Encrypted with org-wide CMEK                          │  │   │
│  │  │ ✓ Dataset-level access controls                         │  │   │
│  │  └────────────────────────────────────────────────────────┘  │   │
│  │                                                                │   │
│  │  ┌────────────────────────────────────────────────────────┐  │   │
│  │  │ Level 3 Runtime - builtin_dataplex.tf (NEW)            │  │   │
│  │  │                                                          │  │   │
│  │  │ ┌────────────────────────────────────────────────────┐ │  │   │
│  │  │ │ Dataplex Lake: analytics-lake                       │ │  │   │
│  │  │ │                                                      │ │  │   │
│  │  │ │ ┌────────────────────────────────────────────────┐ │ │  │   │
│  │  │ │ │ RAW Zone: raw-ingestion                         │ │ │  │   │
│  │  │ │ │                                                  │ │ │  │   │
│  │  │ │ │ Assets:                                         │ │ │  │   │
│  │  │ │ │ • gs://.../raw-data (reference only)           │ │ │  │   │
│  │  │ │ │                                                  │ │ │  │   │
│  │  │ │ │ Metadata Discovery:                             │ │ │  │   │
│  │  │ │ │ • Automatic schema detection                   │ │ │  │   │
│  │  │ │ │ • File format detection                        │ │ │  │   │
│  │  │ │ │ • Indexing for search                          │ │ │  │   │
│  │  │ │ └────────────────────────────────────────────────┘ │ │  │   │
│  │  │ │                                                      │ │  │   │
│  │  │ │ ┌────────────────────────────────────────────────┐ │ │  │   │
│  │  │ │ │ CURATED Zone: analytics-warehouse               │ │ │  │   │
│  │  │ │ │                                                  │ │ │  │   │
│  │  │ │ │ Assets:                                         │ │ │  │   │
│  │  │ │ │ • BigQuery: analytics_warehouse (reference)    │ │ │  │   │
│  │  │ │ │ • BigQuery: customer_360 (reference)           │ │ │  │   │
│  │  │ │ │                                                  │ │ │  │   │
│  │  │ │ │ Metadata Discovery:                             │ │ │  │   │
│  │  │ │ │ • Table schemas                                │ │ │  │   │
│  │  │ │ │ • Column names and types                       │ │ │  │   │
│  │  │ │ │ • Row counts, size                             │ │ │  │   │
│  │  │ │ └────────────────────────────────────────────────┘ │ │  │   │
│  │  │ └────────────────────────────────────────────────────┘ │  │   │
│  │  │                                                          │  │   │
│  │  │ ┌────────────────────────────────────────────────────┐ │  │   │
│  │  │ │ Metadata Catalog                                    │ │  │   │
│  │  │ │ • Entry Groups (customer-data, financial-data)      │ │  │   │
│  │  │ │ • Entry Types (data-asset, table)                   │ │  │   │
│  │  │ │ • Aspect Types (quality-score, owner)               │ │  │   │
│  │  │ └────────────────────────────────────────────────────┘ │  │   │
│  │  │                                                          │  │   │
│  │  │ ┌────────────────────────────────────────────────────┐ │  │   │
│  │  │ │ Business Glossaries                                 │ │  │   │
│  │  │ │ • BigQuery table: glossary_business_terms           │ │  │   │
│  │  │ │ • Searchable via Data Catalog                       │ │  │   │
│  │  │ └────────────────────────────────────────────────────┘ │  │   │
│  │  │                                                          │  │   │
│  │  │ ┌────────────────────────────────────────────────────┐ │  │   │
│  │  │ │ Data Quality Scans                                  │ │  │   │
│  │  │ │ • customer-quality (NON_NULL, UNIQUENESS, REGEX)    │ │  │   │
│  │  │ │ • Schedule: "0 2 * * *" (daily at 2 AM)            │ │  │   │
│  │  │ │ • Results: BigQuery table (encrypted with CMEK)     │ │  │   │
│  │  │ └────────────────────────────────────────────────────┘ │  │   │
│  │  │                                                          │  │   │
│  │  │ ┌────────────────────────────────────────────────────┐ │  │   │
│  │  │ │ Data Profiling Scans                                │ │  │   │
│  │  │ │ • customer-profile (statistical analysis)           │ │  │   │
│  │  │ │ • Schedule: "0 3 * * 0" (weekly)                   │ │  │   │
│  │  │ │ • Results: BigQuery table (encrypted with CMEK)     │ │  │   │
│  │  │ └────────────────────────────────────────────────────┘ │  │   │
│  │  └────────────────────────────────────────────────────────┘  │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                        │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │ Google-Managed Dataplex Service Account (automatic)          │   │
│  │ service-{PROJECT_NUMBER}@gcp-sa-dataplex.iam.gserviceaccount │   │
│  │                                                                │   │
│  │ Permissions (granted by module):                              │   │
│  │ • roles/bigquery.dataViewer - Read BQ for quality scans      │   │
│  │ • roles/storage.objectViewer - Read GCS metadata             │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
                                   ↓
┌────────────────────────────────────────────────────────────────────────┐
│ Cloud Audit Logs (Organization Level)                                  │
│ • All Dataplex API calls logged                                        │
│ • Admin activity: ALWAYS enabled                                       │
│ • Data access: Optional (recommended for production)                   │
│ • Retention: 400 days (configurable)                                   │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 4.2. Component Architecture

### 4.2.1. Dataplex Lake Hierarchy

```
Lake (Top Level)
├── Display Name: "Analytics Data Lake"
├── Description: "Central analytics lake for BI"
├── Labels: {environment=production, team=data-engineering}
│
├── Zone 1: RAW (Unprocessed Data)
│   ├── Type: RAW
│   ├── Display Name: "Raw Data Ingestion"
│   ├── Location Type: SINGLE_REGION
│   │
│   └── Assets:
│       ├── Asset 1: GCS Bucket
│       │   ├── Resource: gs://pru-prod-runtime-analytics-az1-raw-data
│       │   ├── Type: STORAGE_BUCKET
│       │   └── Discovery: Automatic (file formats, sizes)
│       │
│       └── Asset 2: BigQuery Dataset
│           ├── Resource: projects/PROJECT/datasets/raw_data_warehouse
│           ├── Type: BIGQUERY_DATASET
│           └── Discovery: Automatic (tables, schemas)
│
└── Zone 2: CURATED (Processed Data)
    ├── Type: CURATED
    ├── Display Name: "Analytics Warehouse"
    ├── Location Type: SINGLE_REGION
    │
    └── Assets:
        ├── Asset 1: GCS Bucket (Parquet only)
        │   ├── Resource: gs://pru-prod-runtime-analytics-az1-curated-data
        │   ├── Type: STORAGE_BUCKET
        │   └── Requirement: Parquet/Avro/ORC format only
        │
        └── Asset 2: BigQuery Dataset
            ├── Resource: projects/PROJECT/datasets/analytics_warehouse
            ├── Type: BIGQUERY_DATASET
            └── Requirement: Must have schema
```

---

### 4.2.2. Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│ Step 1: ISS Foundation Creates Storage                          │
│                                                                  │
│ builtin_gcs_v2.tf:                                              │
│   → Creates: gs://pru-prod-runtime-analytics-az1-raw-data      │
│   → Encryption: Org-wide CMEK (automatic)                      │
│   → Access: Uniform bucket-level IAM                           │
│                                                                  │
│ builtin_bigquery.tf:                                            │
│   → Creates: BigQuery dataset analytics_warehouse              │
│   → Encryption: Org-wide CMEK (automatic)                      │
│   → Access: Dataset-level IAM                                  │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ Step 2: Dataplex Module Catalogs Existing Resources             │
│                                                                  │
│ builtin_dataplex.tf:                                            │
│   → References: existing_bucket = "pru-prod-...-raw-data"      │
│   → References: existing_dataset = "analytics_warehouse"        │
│   → Does NOT create storage (catalog-only)                     │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ Step 3: Dataplex Automatic Discovery                            │
│                                                                  │
│ Dataplex Service:                                               │
│   → Scans GCS bucket (file formats, sizes, counts)            │
│   → Scans BigQuery dataset (tables, schemas, row counts)      │
│   → Indexes metadata for search                                │
│   → Makes searchable in Data Catalog                           │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ Step 4: Quality/Profiling Scans (Scheduled)                     │
│                                                                  │
│ Quality Scan (Daily):                                           │
│   → Reads BigQuery table                                       │
│   → Validates rules (NON_NULL, UNIQUENESS, etc.)              │
│   → Stores results in BigQuery (encrypted with CMEK)           │
│   → Alerts if quality below threshold                          │
│                                                                  │
│ Profiling Scan (Weekly):                                        │
│   → Analyzes BigQuery table (min, max, null%, distribution)   │
│   → Stores statistics in BigQuery (encrypted with CMEK)        │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ Step 5: Users Discover and Analyze                              │
│                                                                  │
│ Data Analysts:                                                  │
│   → Search Data Catalog for "customer email"                   │
│   → Find tables/files with customer email                      │
│   → View quality scores, profiling stats                       │
│   → Access underlying data (if IAM allows)                     │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4.3. Security Architecture

### 4.3.1. Encryption (Data at Rest)

| Resource | Encryption Method | Key Management | Managed By |
|----------|-------------------|----------------|------------|
| **GCS Buckets** | CMEK | Org-wide KMS keyring | ISS Foundation |
| **BigQuery Datasets** | CMEK | Org-wide KMS keyring | ISS Foundation |
| **Dataplex Metadata** | Google-managed | Google | Google |
| **Quality Scan Results (BQ)** | CMEK | Org-wide KMS keyring | ISS Foundation |
| **Profiling Scan Results (BQ)** | CMEK | Org-wide KMS keyring | ISS Foundation |
| **Glossary Tables (BQ)** | CMEK | Org-wide KMS keyring | ISS Foundation |

**Key Points**:
- ✅ Dataplex module does NOT create or manage encryption keys
- ✅ All data encrypted with org-wide CMEK (managed by ISS Foundation)
- ✅ Automatic key rotation every 90 days
- ✅ HSM protection level

---

### 4.3.2. Encryption (Data in Transit)

```
┌─────────────────────────────────────────────────────────────────┐
│ All Communication Uses TLS 1.2+                                  │
│                                                                  │
│ Terraform → GCP API:                                            │
│   ✓ HTTPS (TLS 1.2+)                                           │
│   ✓ Certificate validation                                      │
│   ✓ Encrypted API calls                                        │
│                                                                  │
│ Dataplex → GCS/BigQuery:                                        │
│   ✓ Google private network                                     │
│   ✓ TLS 1.2+ encryption                                        │
│   ✓ No public internet traversal                               │
│                                                                  │
│ Users → GCP Console:                                            │
│   ✓ HTTPS (TLS 1.3)                                            │
│   ✓ OAuth 2.0 authentication                                   │
│   ✓ Certificate pinning                                        │
└─────────────────────────────────────────────────────────────────┘
```

---

### 4.3.3. IAM & Access Control

**Principle of Least Privilege**:

```
┌──────────────────────────────────────────────────────────────────┐
│ Access Control Matrix                                             │
├──────────────────────────────────────────────────────────────────┤
│ Role                    │ Access Level          │ Scope           │
├──────────────────────────────────────────────────────────────────┤
│ Terraform SA            │ Full (create/update)  │ Project         │
│   • roles/dataplex.admin                                          │
│   • roles/datacatalog.admin                                       │
│   • roles/bigquery.dataEditor                                     │
│                                                                    │
│ Dataplex SA (Google)    │ Read-only (metadata)  │ Project         │
│   • roles/bigquery.dataViewer                                     │
│   • roles/storage.objectViewer                                    │
│                                                                    │
│ Data Analysts           │ View catalog only     │ Lake            │
│   • roles/dataplex.viewer                                         │
│   • roles/datacatalog.viewer                                      │
│                                                                    │
│ Data Engineers          │ Create/update scans   │ Lake            │
│   • roles/dataplex.editor                                         │
│                                                                    │
│ Compliance Officers     │ View audit logs       │ Organization    │
│   • roles/logging.viewer                                          │
└──────────────────────────────────────────────────────────────────┘
```

**Important**:
- ✅ `roles/dataplex.viewer` does NOT grant access to underlying data (GCS/BigQuery)
- ✅ Underlying data access controlled separately by GCS/BigQuery IAM
- ✅ No overly permissive roles (no `roles/owner`, `roles/editor`)

---

### 4.3.4. Audit Logging

**All Operations Logged**:

```yaml
Admin Activity Logs (ALWAYS enabled, cannot be disabled):
  - dataplex.lakes.create
  - dataplex.lakes.update
  - dataplex.lakes.delete
  - dataplex.zones.create
  - dataplex.assets.create
  - dataplex.datascans.create
  - datacatalog.entryGroups.create
  # ... all administrative operations

Data Access Logs (OPTIONAL, recommended for production):
  - dataplex.lakes.get
  - dataplex.assets.list
  - datacatalog.entries.search
  # ... all read operations

Retention:
  - Admin Activity: 400 days (configurable up to 3650 days)
  - Data Access: 30 days default (configurable)
```

**Example Audit Log Entry**:

```json
{
  "protoPayload": {
    "serviceName": "dataplex.googleapis.com",
    "methodName": "google.cloud.dataplex.v1.DataplexService.CreateLake",
    "authenticationInfo": {
      "principalEmail": "terraform-sa@project.iam.gserviceaccount.com"
    },
    "requestMetadata": {
      "callerIp": "10.x.x.x",
      "callerSuppliedUserAgent": "Terraform/1.5.0"
    },
    "resourceName": "projects/project-id/locations/us-central1/lakes/analytics-lake",
    "request": {
      "@type": "type.googleapis.com/google.cloud.dataplex.v1.CreateLakeRequest",
      "lakeId": "analytics-lake",
      "lake": {
        "displayName": "Analytics Data Lake"
      }
    }
  },
  "timestamp": "2025-01-08T10:00:00Z",
  "severity": "NOTICE"
}
```

---

## 4.4. Deployment Architecture

### 4.4.1. Terraform Module Structure

```
dataplex-universal-catalog-tf-module/
├── main.tf                      # Root module (orchestrates submodules)
├── variables.tf                 # Input variables
├── outputs.tf                   # Output values
├── versions.tf                  # Terraform and provider versions
│
├── modules/
│   ├── manage-lakes/            # Lakes, zones, assets
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── manage-metadata/         # Entry groups, types, aspects
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── govern/                  # Quality scans, profiling, glossaries
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── examples/
│   └── example/                 # Complete working example
│       ├── main.tf
│       ├── terraform.tfvars
│       └── README.md
│
└── docs/
    ├── README.md                # User guide
    ├── RFC_DATAPLEX.md          # This document
    ├── SECURITY_DISCOVERY.md    # Security analysis
    └── ISS_INTEGRATION.md       # ISS Foundation integration guide
```

---

### 4.4.2. CI/CD Pipeline (Jenkins)

```
┌────────────────────────────────────────────────────────────────┐
│ Standard ISS Foundation Jenkins Pipeline                        │
└────────────────────────────────────────────────────────────────┘

Step 1: Developer Updates tfvars
  └─> gcp-foundation/tfvars/pru/prod/projects/analytics.tfvars
      └─> Add dataplex_lakes block

Step 2: Commit to Git (BitBucket)
  └─> git add terraform.tfvars
  └─> git commit -m "Add Dataplex catalog"
  └─> git push origin master

Step 3: Trigger Jenkins Pipeline
  └─> Jenkins job: app-ref-terraform-apply
  └─> Build with Parameters
      └─> Select: Apply

Step 4: Jenkins Execution
  ┌───────────────────────────────────────────────┐
  │ 1. Checkout Code                              │
  │    └─> git clone gcp-foundation               │
  ├───────────────────────────────────────────────┤
  │ 2. Terraform Init                             │
  │    └─> terraform init                         │
  │    └─> Backend: GCS bucket                    │
  ├───────────────────────────────────────────────┤
  │ 3. Terraform Plan                             │
  │    └─> terraform plan -out=tfplan             │
  │    └─> Review changes                         │
  ├───────────────────────────────────────────────┤
  │ 4. Manual Approval (if enabled)               │
  │    └─> Wait for approval                      │
  ├───────────────────────────────────────────────┤
  │ 5. Terraform Apply                            │
  │    └─> terraform apply tfplan                 │
  │    └─> Deploy Dataplex resources              │
  ├───────────────────────────────────────────────┤
  │ 6. Post-Deployment Validation                 │
  │    └─> Verify lakes created                   │
  │    └─> Verify assets discovered               │
  │    └─> Check audit logs                       │
  └───────────────────────────────────────────────┘

Step 5: Verification
  └─> gcloud dataplex lakes list --project=PROJECT --location=REGION
  └─> Check GCP Console: Dataplex → Lakes
```

---

## 4.5. Resource Dependencies

**Deployment Order**:

```
1. ISS Foundation Infrastructure (MUST exist first)
   ├── builtin_gcs_v2.tf       → Creates GCS buckets
   ├── builtin_bigquery.tf     → Creates BigQuery datasets
   └── Org-wide CMEK keys      → Already configured

2. Dataplex Module (deploys second)
   ├── builtin_dataplex.tf     → References existing storage
   └── Depends on: GCS buckets + BigQuery datasets exist

Terraform Dependency:
  module "project_dataplex" {
    # ... configuration ...

    # Explicit dependency (optional, implicit via references)
    depends_on = [
      module.project_gcs_buckets,
      module.project_bigquery_datasets
    ]
  }
```

---

# 5. ISS Foundation Integration

## 5.1. Integration Overview

### What is ISS Foundation?

**ISS (Infrastructure Self-Service) Foundation** is a standardized GCP infrastructure framework that provides:

- 🏗️ **Standardized Terraform modules** (`builtin_gcs_v2.tf`, `builtin_bigquery.tf`, etc.)
- 🔐 **Org-wide CMEK encryption** managed at organization level
- 🏷️ **Consistent naming** patterns (`{lbu}-{env}-{stage}-{appref}-{az}-{name}`)
- 🏛️ **Hierarchical structure** (Level 1: Org → Level 2: Network → Level 3: Runtime)
- 🔄 **CI/CD pipelines** (Jenkins for automated deployment)

### How Dataplex Fits In

```
ISS Foundation Level 3 (Runtime)
├── builtin_gcs_v2.tf         ← Creates GCS buckets (with CMEK)
├── builtin_bigquery.tf       ← Creates BigQuery datasets (with CMEK)
├── builtin_datastream.tf     ← Creates Datastream resources (CDC)
└── builtin_dataplex.tf       ← NEW: Catalogs all resources above
```

**Key Principle**: **Separation of Concerns**

| Module | Responsibility | Creates |
|--------|---------------|---------|
| `builtin_gcs_v2.tf` | Storage infrastructure | GCS buckets (encrypted) |
| `builtin_bigquery.tf` | Data warehouse infrastructure | BigQuery datasets (encrypted) |
| `builtin_datastream.tf` | CDC replication | Datastream connections, streams |
| `builtin_dataplex.tf` | **Data cataloging & governance** | **Dataplex lakes, zones, assets** |

---

## 5.2. Step-by-Step Integration

### Step 1: Add `builtin_dataplex.tf` to Level 3 Runtime (One-Time Setup)

**File**: `gcp-foundation/blueprints/level3/runtime_v2/builtin_dataplex.tf`

```hcl
# ==============================================================================
# Dataplex Universal Catalog Module
# Catalogs existing GCS buckets and BigQuery datasets created by ISS Foundation
# ==============================================================================

variable "dataplex_lakes" {
  type        = any
  default     = {}
  description = "Configuration for Dataplex lakes and cataloging"
}

locals {
  dataplex_lakes = var.dataplex_lakes
}

module "project_dataplex" {
  for_each = local.dataplex_lakes

  # Use ISS Foundation-optimized branch (catalog-only)
  source = "git::https://github.com/Abhishek-Kraj/Dataplex-Universal-Catalog.git?ref=feature/iss-foundation"

  # ========================================================================
  # These values come from ISS Foundation locals - DO NOT MODIFY
  # ========================================================================
  project_id = local.project_id
  region     = local.availability_regions[lookup(each.value, "location", "az1")]
  location   = local.availability_regions[lookup(each.value, "location", "az1")]

  # ========================================================================
  # Module Toggles
  # ========================================================================
  enable_manage_lakes = lookup(each.value, "enable_manage_lakes", true)
  enable_metadata     = lookup(each.value, "enable_metadata", true)
  enable_governance   = lookup(each.value, "enable_governance", true)

  # ========================================================================
  # Feature Flags
  # ISS Foundation handles security and processing, so disable these
  # ========================================================================
  enable_manage     = true
  enable_secure     = false  # ISS Foundation handles IAM
  enable_process    = false  # ISS Foundation handles Spark jobs
  enable_catalog    = lookup(each.value, "enable_catalog", true)
  enable_glossaries = lookup(each.value, "enable_glossaries", true)
  enable_quality    = lookup(each.value, "enable_quality", true)
  enable_profiling  = lookup(each.value, "enable_profiling", true)
  enable_monitoring = lookup(each.value, "enable_monitoring", false)

  # ========================================================================
  # Configuration
  # ========================================================================
  lakes = lookup(each.value, "lakes", [])

  entry_groups  = lookup(each.value, "entry_groups", [])
  entry_types   = lookup(each.value, "entry_types", [])
  aspect_types  = lookup(each.value, "aspect_types", [])
  glossaries    = lookup(each.value, "glossaries", [])

  quality_scans   = lookup(each.value, "quality_scans", [])
  profiling_scans = lookup(each.value, "profiling_scans", [])

  # ========================================================================
  # Apply ISS Foundation Standard Labels
  # ========================================================================
  labels = {
    lbu    = local.lbu
    env    = local.env
    stage  = local.stage
    appref = local.appref
  }
}

# ==============================================================================
# Outputs
# ==============================================================================

output "dataplex_lakes" {
  value = {
    for key, lake in module.project_dataplex :
    key => {
      lakes         = lake.lakes
      entry_groups  = lake.entry_groups
      quality_scans = lake.quality_scans
    }
  }
  description = "Created Dataplex lakes and catalog resources"
}
```

**Key Points**:
- ✅ Use `ref=feature/iss-foundation` branch (catalog-only, no storage creation)
- ✅ `project_id`, `region`, `location` come from ISS Foundation locals
- ✅ `enable_secure = false` and `enable_process = false` (ISS Foundation handles)
- ✅ Labels use ISS Foundation standard: `lbu`, `env`, `stage`, `appref`

---

### Step 2: Add Configuration to App-Ref terraform.tfvars (Per Project)

**File**: `gcp-foundation/tfvars/{lbu}/{env}/projects/{project}.tfvars`

**Example**: `gcp-foundation/tfvars/pru/prod/projects/analytics.tfvars`

```hcl
# ==============================================================================
# STEP 1: GCS Buckets (Existing ISS Foundation Code - DO NOT MODIFY)
# ==============================================================================
# These buckets are created by builtin_gcs_v2.tf with org-wide CMEK encryption

gcs_buckets_v2 = {
  "raw-data" : {
    storage_class = "STANDARD"
    location      = "az1"
  },
  "curated-data" : {
    storage_class = "STANDARD"
    location      = "az1"
  }
}

# ISS Foundation creates buckets with FULL names:
# • pru-prod-runtime-analytics-az1-raw-data
# • pru-prod-runtime-analytics-az1-curated-data

# ==============================================================================
# STEP 2: BigQuery Datasets (Existing ISS Foundation Code - DO NOT MODIFY)
# ==============================================================================
# These datasets are created by builtin_bigquery.tf with org-wide CMEK encryption

bigquery_datasets = {
  "analytics_warehouse" : {
    location = "az1"
    tables = [
      {
        table_id = "customers"
        schema   = "./schemas/customers.json"
        clustering = ["customer_id"]
      }
    ]
  },
  "customer_360" : {
    location = "az1"
  }
}

# ==============================================================================
# STEP 3: Dataplex Cataloging (NEW - Add this block)
# ==============================================================================
# Catalog the resources created above (references only, no new infrastructure)

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

        labels = {
          domain = "analytics"
          tier   = "production"
        }

        zones = [
          # ================================================================
          # RAW Zone with GCS Bucket
          # ================================================================
          {
            zone_id      = "raw-ingestion"
            type         = "RAW"
            display_name = "Raw Data Ingestion"
            description  = "Landing zone for raw data files"

            # ⚠️ CRITICAL: Use FULL bucket name as created by ISS Foundation
            # Pattern: ${LBU}-${ENV}-${STAGE}-${APPREF}-${AZ}-{bucket-name}
            # Example: pru-prod-runtime-analytics-az1-raw-data
            existing_bucket = "${LBU}-${ENV}-${STAGE}-${APPREF}-${AZ}-raw-data"
          },

          # ================================================================
          # CURATED Zone with BigQuery Dataset
          # ================================================================
          {
            zone_id      = "analytics-warehouse"
            type         = "CURATED"
            display_name = "Analytics Warehouse"
            description  = "Curated data for analytics and reporting"

            # ⚠️ CRITICAL: Use the EXACT key from bigquery_datasets above
            # NOT the full table path, just the dataset key
            existing_dataset = "analytics_warehouse"
          },

          # ================================================================
          # CURATED Zone with GCS Bucket (Parquet files)
          # ================================================================
          {
            zone_id      = "curated-parquet"
            type         = "CURATED"
            display_name = "Curated Parquet Data"
            description  = "Processed data in Parquet format"

            existing_bucket = "${LBU}-${ENV}-${STAGE}-${APPREF}-${AZ}-curated-data"
          }
        ]
      }
    ]

    # ========================================================================
    # Metadata Catalog
    # ========================================================================

    entry_groups = [
      {
        entry_group_id = "customer-data"
        display_name   = "Customer Data Assets"
        description    = "All customer-related data assets"
      },
      {
        entry_group_id = "financial-data"
        display_name   = "Financial Data Assets"
        description    = "Financial records and transactions"
      }
    ]

    entry_types = [
      {
        entry_type_id = "data-asset"
        display_name  = "Data Asset"
        description   = "Standard data asset entry type"

        required_aspects = [
          { aspect_type = "data-quality-aspect" }
        ]
      }
    ]

    aspect_types = [
      {
        aspect_type_id = "data-quality-aspect"
        display_name   = "Data Quality Metadata"
        description    = "Quality metrics for data assets"

        metadata_template = {
          name = "Data Quality"
          fields = [
            {
              field_id     = "quality_score"
              display_name = "Quality Score"
              type         = "DOUBLE"
              is_required  = true
            },
            {
              field_id     = "last_validated"
              display_name = "Last Validated"
              type         = "TIMESTAMP"
              is_required  = false
            }
          ]
        }
      }
    ]

    # ========================================================================
    # Business Glossaries
    # ========================================================================

    glossaries = [
      {
        glossary_id  = "business-terms"
        display_name = "Business Glossary"
        description  = "Standard business terminology"

        terms = [
          {
            term_id      = "customer"
            display_name = "Customer"
            description  = "An individual or organization that purchases goods or services from us"
          },
          {
            term_id      = "revenue"
            display_name = "Revenue"
            description  = "Total income generated from sales of goods or services"
          },
          {
            term_id      = "churn_rate"
            display_name = "Churn Rate"
            description  = "Percentage of customers who stop using our service in a given period"
          }
        ]
      }
    ]

    # ========================================================================
    # Data Quality Scans
    # ========================================================================

    quality_scans = [
      {
        scan_id      = "customer-quality"
        lake_id      = "analytics-lake"
        display_name = "Customer Data Quality"
        description  = "Validate customer master data quality"

        # ⚠️ CRITICAL: Use full BigQuery table path
        data_source = "//bigquery.googleapis.com/projects/${PROJECT_ID}/datasets/analytics_warehouse/tables/customers"

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
            pattern    = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
            threshold  = 0.95
            dimension  = "VALIDITY"
          }
        ]

        schedule = "0 2 * * *"  # Daily at 2 AM
      }
    ]

    # ========================================================================
    # Data Profiling Scans
    # ========================================================================

    profiling_scans = [
      {
        scan_id      = "customer-profile"
        lake_id      = "analytics-lake"
        display_name = "Customer Data Profiling"
        description  = "Statistical analysis of customer data"

        data_source = "//bigquery.googleapis.com/projects/${PROJECT_ID}/datasets/analytics_warehouse/tables/customers"

        schedule = "0 3 * * 0"  # Weekly on Sunday at 3 AM
      }
    ]
  }
}
```

---

### Step 3: Naming Conventions - CRITICAL

#### For GCS Buckets:

```hcl
# ============================================================================
# In gcs_buckets_v2, you define the SHORT name:
# ============================================================================
gcs_buckets_v2 = {
  "raw-data" : { ... }  # ← SHORT name
}

# ============================================================================
# ISS Foundation creates bucket with FULL name:
# ============================================================================
# Pattern: ${LBU}-${ENV}-${STAGE}-${APPREF}-${AZ}-{bucket-name}
# Example: pru-prod-runtime-analytics-az1-raw-data

# ============================================================================
# In dataplex_lakes, use the FULL name:
# ============================================================================
existing_bucket = "${LBU}-${ENV}-${STAGE}-${APPREF}-${AZ}-raw-data"

# ⚠️ WRONG:
existing_bucket = "raw-data"  # Too short!

# ✅ CORRECT:
existing_bucket = "pru-prod-runtime-analytics-az1-raw-data"  # Full ISS name
```

#### For BigQuery Datasets:

```hcl
# ============================================================================
# In bigquery_datasets, the KEY is the dataset ID:
# ============================================================================
bigquery_datasets = {
  "analytics_warehouse" : { ... }  # ← This IS the dataset ID
}

# ============================================================================
# In dataplex_lakes, use the EXACT same key:
# ============================================================================
existing_dataset = "analytics_warehouse"  # ← Same as above

# ⚠️ WRONG:
existing_dataset = "projects/PROJECT/datasets/analytics_warehouse"  # Too long!

# ✅ CORRECT:
existing_dataset = "analytics_warehouse"  # Just the dataset ID
```

---

### Step 4: Deploy via Jenkins

**Standard ISS Foundation Workflow**:

```bash
# 1. Update terraform.tfvars
cd gcp-foundation/tfvars/pru/prod/projects
vim analytics.tfvars  # Add dataplex_lakes block

# 2. Commit changes
git add analytics.tfvars
git commit -m "Add Dataplex catalog for analytics project"
git push origin master

# 3. Trigger Jenkins pipeline
# Navigate to Jenkins → Select app-ref project → Build with Parameters

# 4. Verify deployment
gcloud dataplex lakes list --project=pru-prod-runtime-analytics-az1 --location=asia-southeast1
```

---

## 5.3. Integration Benefits

✅ **Single Deployment** - All infrastructure (storage + catalog) deployed together
✅ **No Duplication** - Storage defined once in ISS Foundation, referenced by Dataplex
✅ **Consistent Encryption** - Org-wide CMEK applied automatically
✅ **Consistent Naming** - ISS Foundation naming patterns maintained
✅ **Standard CI/CD** - Uses existing Jenkins pipelines
✅ **Version Controlled** - All configuration in Git (BitBucket)

---

# 6. Security & Compliance

> **For comprehensive security analysis, see [SECURITY_DISCOVERY.md](SECURITY_DISCOVERY.md)**

## 6.1. Security Summary

### Encryption

| Data State | Method | Key Management | Rotation |
|------------|--------|----------------|----------|
| **Data at Rest (GCS)** | CMEK | ISS Foundation (org-wide) | Automatic (90 days) |
| **Data at Rest (BigQuery)** | CMEK | ISS Foundation (org-wide) | Automatic (90 days) |
| **Data in Transit** | TLS 1.2+ | Google-managed | Automatic |
| **Dataplex Metadata** | Google-managed | Google | Automatic |

### Access Control

| Level | Mechanism | Principle |
|-------|-----------|-----------|
| **Organization** | IAM policies | Least privilege |
| **Project** | IAM policies | Separation of duties |
| **Lake** | IAM bindings | Role-based access |
| **Underlying Data** | GCS/BigQuery IAM | Data-level security |

### Audit & Compliance

| Compliance Framework | Status | Notes |
|---------------------|--------|-------|
| **SOC 2 Type II** | ✅ Compliant | Audit logs, encryption, access controls |
| **ISO 27001** | ✅ Compliant | Information security management |
| **GDPR** | ✅ Compliant | Encryption, audit trails, right to deletion |
| **HIPAA** | ⚠️ Conditional | Requires BAA with Google |
| **PCI-DSS** | ⚠️ Conditional | Module only catalogs metadata |

---

## 6.2. Threat Model (High-Level)

| Threat | Likelihood | Impact | Mitigation | Residual Risk |
|--------|-----------|--------|------------|---------------|
| **Unauthorized metadata access** | Low | Medium | IAM, VPC-SC, audit logs | **LOW** |
| **Data exfiltration via scans** | Low | High | Read-only SA, statistics-only results | **LOW** |
| **Service account compromise** | Low | Medium | Workload Identity, audit logs | **LOW** |
| **Encryption key compromise** | Very Low | High | HSM, key rotation, Google-managed | **VERY LOW** |
| **Insider threat** | Very Low | Medium | Audit logs, separation of duties | **LOW** |

**Overall Risk Assessment**: **LOW**

---

## 6.3. Compliance Checklist

### Pre-Deployment Security Review

```yaml
Encryption:
  ☐ CMEK configured for all data at rest (ISS Foundation)
  ☐ TLS 1.2+ for all API calls (automatic)
  ☐ Key rotation enabled (90 days)

Access Control:
  ☐ Terraform SA has minimum required permissions
  ☐ Dataplex SA granted read-only permissions only
  ☐ No overly permissive IAM bindings (roles/owner, roles/editor)
  ☐ Principle of least privilege applied

Audit Logging:
  ☐ Admin activity logs enabled (automatic)
  ☐ Data access logs enabled (recommended for production)
  ☐ Log retention meets compliance requirements (400 days+)
  ☐ Log exports configured to Cloud Storage

Data Privacy:
  ☐ Module only catalogs metadata (no direct data access)
  ☐ Quality scan results contain statistics only (no raw data)
  ☐ Data residency requirements met (regional deployment)
  ☐ PII handling documented and approved

Compliance:
  ☐ Security team approval obtained
  ☐ Compliance team approval obtained (if applicable)
  ☐ Risk assessment completed and accepted
  ☐ Security testing completed (pre/post-deployment validation)
```

---

# 7. Implementation Plan

## 7.1. Project Phases

### Phase 1: Preparation (Week 1)

**Objectives**:
- ✅ Security team reviews RFC and Security Discovery Document
- ✅ Architecture team reviews technical design
- ✅ Compliance team reviews compliance requirements
- ✅ Obtain all necessary approvals

**Deliverables**:
- Signed approval from Security, Architecture, Compliance teams
- Risk acceptance from business owner
- Implementation plan approved

---

### Phase 2: Development (Week 2)

**Objectives**:
- ✅ Add `builtin_dataplex.tf` to ISS Foundation Level 3 runtime
- ✅ Test in sandbox environment (`prusandbx`)
- ✅ Create documentation and examples
- ✅ Validate deployment process

**Deliverables**:
- `builtin_dataplex.tf` module added to gcp-foundation repository
- Complete tfvars examples for different use cases
- Deployment tested in sandbox environment
- Documentation updated

---

### Phase 3: Pilot Deployment (Week 3)

**Objectives**:
- ✅ Deploy to 1-2 pilot projects (non-production)
- ✅ Validate functionality (cataloging, quality scans, glossaries)
- ✅ Collect feedback from users (data analysts, engineers)
- ✅ Refine configuration based on feedback

**Deliverables**:
- Pilot projects deployed successfully
- User feedback collected and documented
- Configuration refined based on feedback
- Runbooks and troubleshooting guides updated

---

### Phase 4: Production Rollout (Week 4-6)

**Objectives**:
- ✅ Deploy to production projects (phased approach)
- ✅ Train data analysts and engineers on using Data Catalog
- ✅ Set up monitoring and alerting
- ✅ Establish support processes

**Deliverables**:
- Production projects deployed
- Training sessions conducted
- Monitoring dashboards and alerts configured
- Support runbooks available

---

### Phase 5: Operationalization (Ongoing)

**Objectives**:
- ✅ Monitor quality scan results
- ✅ Continuously improve business glossaries
- ✅ Expand cataloging to additional projects
- ✅ Optimize costs and performance

**Deliverables**:
- Regular quality reports
- Updated business glossaries
- Cost optimization recommendations
- Performance tuning as needed

---

## 7.2. Deployment Checklist

### Pre-Deployment

```yaml
Prerequisites:
  ☐ GCS buckets exist (created by builtin_gcs_v2.tf)
  ☐ BigQuery datasets exist (created by builtin_bigquery.tf)
  ☐ Org-wide CMEK keys configured
  ☐ Terraform SA has required permissions

Configuration:
  ☐ builtin_dataplex.tf added to Level 3 runtime
  ☐ terraform.tfvars updated with dataplex_lakes block
  ☐ Naming conventions followed (full bucket names, dataset IDs)
  ☐ Configuration validated (terraform fmt, terraform validate)

Approvals:
  ☐ Security team approval
  ☐ Architecture team approval
  ☐ Compliance team approval (if applicable)
  ☐ Change management approval (for production)
```

### Deployment

```yaml
Execution:
  ☐ Terraform init (backend initialization)
  ☐ Terraform plan (review changes)
  ☐ Manual approval (if required)
  ☐ Terraform apply (deploy resources)

Validation:
  ☐ Lakes created successfully
  ☐ Zones created successfully
  ☐ Assets discovered (GCS buckets, BigQuery datasets)
  ☐ Quality scans configured and scheduled
  ☐ Profiling scans configured and scheduled
  ☐ Business glossaries created
  ☐ IAM bindings applied (if configured)
```

### Post-Deployment

```yaml
Verification:
  ☐ gcloud dataplex lakes list (verify lakes exist)
  ☐ Check GCP Console → Dataplex → Lakes
  ☐ Search Data Catalog (verify assets searchable)
  ☐ Check audit logs (verify operations logged)
  ☐ Run quality scan manually (verify scans work)
  ☐ Check BigQuery (verify scan results stored)

Documentation:
  ☐ Update runbooks with project-specific details
  ☐ Document lake/zone structure
  ☐ Share Data Catalog access with users
  ☐ Conduct training session (if needed)
```

---

## 7.3. Rollback Plan

### Scenario 1: Deployment Failed

**Symptoms**: Terraform apply failed with errors

**Actions**:
1. Review error messages in Jenkins/Terraform output
2. Fix configuration errors in terraform.tfvars
3. Re-run terraform plan to verify fixes
4. Re-run terraform apply

**Rollback** (if needed):
```bash
# Destroy all Dataplex resources
terraform destroy -target=module.project_dataplex

# Note: Does NOT affect underlying storage (GCS, BigQuery)
```

---

### Scenario 2: Incorrect Configuration Deployed

**Symptoms**: Wrong buckets/datasets cataloged, incorrect quality scans

**Actions**:
1. Pull previous Terraform state from backup (GCS bucket)
2. Update terraform.tfvars with correct configuration
3. Re-run terraform apply

**Rollback**:
```bash
# Option 1: Destroy specific resources
terraform destroy -target=module.project_dataplex.google_dataplex_datascan.quality_scans[\"scan-id\"]

# Option 2: Destroy all and redeploy
terraform destroy -target=module.project_dataplex
# Fix configuration
terraform apply
```

---

## 7.4. Success Criteria

### Technical Success Criteria

✅ All Dataplex resources deployed successfully (lakes, zones, assets, scans)
✅ Assets discovered automatically (metadata indexed)
✅ Quality scans running on schedule (no failures)
✅ Profiling scans completing successfully
✅ Business glossaries searchable in Data Catalog
✅ Audit logs show all operations
✅ No security vulnerabilities detected

### Business Success Criteria

✅ Data analysts can find data 10x faster than before
✅ Data quality issues detected early (before reports fail)
✅ Business glossary used by 80%+ of data users
✅ 100% of production data assets cataloged
✅ Compliance requirements met (audit trails, metadata)
✅ Zero security incidents related to Dataplex

---

# 8. Operations & Monitoring

## 8.1. Operational Responsibilities

| Responsibility | Team | Frequency |
|---------------|------|-----------|
| **Monitor quality scan results** | Data Quality Team | Daily |
| **Review and update business glossaries** | Data Governance Team | Monthly |
| **Review IAM bindings** | Security Team | Quarterly |
| **Cost optimization** | Platform Team | Monthly |
| **Terraform module updates** | Platform Team | As needed |
| **User training** | Data Platform Team | Quarterly |

---

## 8.2. Monitoring Dashboards

### Cloud Monitoring Metrics

```yaml
Dataplex Service Metrics:
  - dataplex.googleapis.com/lake/asset_count
    Alert: If asset count drops unexpectedly

  - dataplex.googleapis.com/datascan/execution_count
    Alert: If scans stop running

  - dataplex.googleapis.com/datascan/execution_duration
    Alert: If scans take > 30 minutes

  - dataplex.googleapis.com/datascan/execution_status
    Alert: If scans fail

BigQuery Metrics (for scan results):
  - bigquery.googleapis.com/storage/stored_bytes
    Alert: If storage grows unexpectedly

  - bigquery.googleapis.com/query/execution_times
    Alert: If scan queries slow down
```

### Recommended Alerts

```yaml
Alert 1: Quality Scan Failures
  Condition: datascan/execution_status = FAILED
  Threshold: > 1 failure
  Notification: Email to data-quality@company.com
  Severity: Medium

Alert 2: Asset Discovery Errors
  Condition: asset/discovery_status = ERROR
  Threshold: Duration > 5 minutes
  Notification: Email to platform-team@company.com
  Severity: High

Alert 3: API Quota Exhaustion
  Condition: API quota usage > 80%
  Threshold: Duration > 10 minutes
  Notification: Email to platform-team@company.com
  Severity: High

Alert 4: Scan Schedule Drift
  Condition: Scan hasn't run in expected interval
  Threshold: > 2 hours past expected time
  Notification: Email to data-quality@company.com
  Severity: Medium
```

---

## 8.3. Operational Runbooks

### Runbook 1: Quality Scan Failed

**Symptoms**: Quality scan failed, alert received

**Diagnosis**:
```bash
# 1. Check scan status
gcloud dataplex datascans describe SCAN_ID \
  --location=REGION \
  --format=json

# 2. Check scan execution logs
gcloud logging read \
  'resource.type="dataplex.googleapis.com/DataScan" AND resource.labels.datascan_id="SCAN_ID"' \
  --limit=50 \
  --format=json

# 3. Check BigQuery table exists
bq show PROJECT:DATASET.TABLE

# 4. Check Dataplex SA permissions
gcloud projects get-iam-policy PROJECT \
  --flatten="bindings[].members" \
  --filter="bindings.members:service-*@gcp-sa-dataplex.iam.gserviceaccount.com"
```

**Resolution**:

**Scenario A: Table doesn't exist**
- Fix: Ensure BigQuery table exists before running scan
- Action: Create table or update data_source in scan configuration

**Scenario B: Permission denied**
- Fix: Grant Dataplex SA required permissions
- Action:
  ```bash
  gcloud projects add-iam-policy-binding PROJECT \
    --member="serviceAccount:service-PROJECT_NUMBER@gcp-sa-dataplex.iam.gserviceaccount.com" \
    --role="roles/bigquery.dataViewer"
  ```

**Scenario C: Data quality issue (threshold not met)**
- Fix: This is expected behavior (data quality below threshold)
- Action:
  1. Review scan results in BigQuery
  2. Identify root cause of data quality issue
  3. Fix upstream data pipeline
  4. Re-run scan to verify fix

**Scenario D: Scan configuration error**
- Fix: Update scan configuration in terraform.tfvars
- Action:
  1. Fix configuration (column name, rule type, etc.)
  2. Run terraform plan and apply
  3. Manually trigger scan to verify fix

---

### Runbook 2: Asset Not Discovered

**Symptoms**: GCS bucket or BigQuery dataset not appearing in Dataplex

**Diagnosis**:
```bash
# 1. Verify resource exists
gsutil ls gs://BUCKET_NAME
bq ls --project_id=PROJECT

# 2. Check Dataplex asset configuration
gcloud dataplex assets describe ASSET_ID \
  --location=REGION \
  --lake=LAKE \
  --zone=ZONE

# 3. Check asset discovery status
gcloud dataplex assets describe ASSET_ID \
  --location=REGION \
  --lake=LAKE \
  --zone=ZONE \
  --format="get(discoveryStatus)"
```

**Resolution**:

**Scenario A: Resource doesn't exist**
- Fix: Create bucket/dataset first (via builtin_gcs_v2.tf or builtin_bigquery.tf)
- Action: Deploy storage resources before Dataplex

**Scenario B: Incorrect resource reference**
- Fix: Update asset configuration with correct bucket/dataset name
- Action:
  ```hcl
  # In terraform.tfvars, fix:
  existing_bucket = "pru-prod-runtime-analytics-az1-raw-data"  # Full ISS name
  # NOT:
  existing_bucket = "raw-data"  # Too short
  ```

**Scenario C: Discovery in progress**
- Fix: Wait for discovery to complete (can take up to 1 hour)
- Action: Check back in 1 hour, no action needed

**Scenario D: Permission issue**
- Fix: Grant Dataplex SA permissions to read bucket/dataset metadata
- Action:
  ```bash
  # For GCS
  gsutil iam ch serviceAccount:service-PROJECT_NUMBER@gcp-sa-dataplex.iam.gserviceaccount.com:objectViewer gs://BUCKET

  # For BigQuery
  bq add-iam-policy-binding PROJECT:DATASET \
    --member="serviceAccount:service-PROJECT_NUMBER@gcp-sa-dataplex.iam.gserviceaccount.com" \
    --role="roles/bigquery.dataViewer"
  ```

---

### Runbook 3: High BigQuery Costs from Scans

**Symptoms**: BigQuery costs increased after deploying Dataplex

**Diagnosis**:
```bash
# 1. Query BigQuery audit logs to identify expensive scans
bq query --use_legacy_sql=false \
  'SELECT
     protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobName.jobId,
     protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobStatistics.totalBilledBytes,
     protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobConfiguration.query.query
   FROM `PROJECT.dataset_id.cloudaudit_googleapis_com_data_access_*`
   WHERE protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.eventName = "query_job_completed"
   AND protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobStatistics.totalBilledBytes > 1000000000
   ORDER BY protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobStatistics.totalBilledBytes DESC
   LIMIT 20'

# 2. Check Dataplex scan schedules
gcloud dataplex datascans list --location=REGION --format="table(name,schedule)"
```

**Resolution**:

**Scenario A: Scans running too frequently**
- Fix: Reduce scan frequency
- Action:
  ```hcl
  # In terraform.tfvars, change schedule:
  # FROM: schedule = "0 * * * *"  # Hourly
  # TO:   schedule = "0 2 * * *"  # Daily at 2 AM
  ```

**Scenario B: Scanning large tables unnecessarily**
- Fix: Only scan critical tables
- Action: Remove quality scans from non-critical tables

**Scenario C: Profiling scans on very large tables**
- Fix: Reduce profiling frequency or use sampling
- Action:
  ```hcl
  # Change from daily to weekly:
  schedule = "0 3 * * 0"  # Weekly on Sunday
  ```

---

## 8.4. Backup and Recovery

### Terraform State Backup

**Automatic Backup** (ISS Foundation handles this):
- Terraform state stored in GCS bucket with versioning enabled
- Previous state versions retained automatically
- State encrypted with CMEK

**Manual Backup** (before major changes):
```bash
# Pull current state and save to local file
terraform state pull > terraform.tfstate.backup.$(date +%Y%m%d_%H%M%S)

# Upload to separate backup location
gsutil cp terraform.tfstate.backup.* gs://backup-bucket/dataplex/
```

### Disaster Recovery

**Scenario**: Regional outage, Dataplex unavailable

**Impact**:
- Dataplex catalog unavailable during outage
- Underlying data (GCS, BigQuery) unaffected (stored redundantly)
- Quality/profiling scans paused

**Recovery**:
- Automatic: Dataplex service recovers when region recovers
- Manual: If region permanently lost, redeploy to different region using Terraform

**Recovery Steps**:
```bash
# 1. Create new Terraform workspace for different region
terraform workspace new us-central1

# 2. Update terraform.tfvars with new region
location = "us-central1"

# 3. Deploy Dataplex resources in new region
terraform apply

# 4. Dataplex will re-discover assets automatically
```

**Recovery Time Objective (RTO)**: < 1 hour (automatic region recovery) or < 4 hours (manual redeployment)

**Recovery Point Objective (RPO)**: 0 (metadata catalog, no data loss)

---

# 9. Cost Analysis

## 9.1. Pricing Model

### Dataplex Pricing (Pay-per-Use)

| Component | Pricing | Notes |
|-----------|---------|-------|
| **Managed Storage (metadata)** | **FREE** | Lakes, zones, assets, entry groups |
| **Metadata Management** | **FREE** | Entry types, aspect types |
| **Data Profiling** | **$1.00 per 1 TB scanned** | Statistical analysis of tables |
| **Data Quality Scans** | **$0.10 per 1 GB scanned** | Validation rules (NON_NULL, etc.) |
| **BigQuery Storage** | **Standard pricing** | For glossary tables, scan results |
| **BigQuery Queries** | **Standard pricing** | Scan execution uses slots |

**Reference**: [Dataplex Pricing](https://cloud.google.com/dataplex/pricing)

---

### Cost Examples

#### Example 1: Small Deployment (10 tables, 100 GB each)

```
Assumptions:
  - 10 BigQuery tables
  - 100 GB per table = 1 TB total
  - Quality scans: Daily (30/month)
  - Profiling scans: Weekly (4/month)

Costs per month:
  Managed Storage:       $0.00 (FREE)
  Quality Scans:         10 tables × 100 GB × 30 scans × $0.10/GB = $3,000.00
  Profiling Scans:       10 tables × 100 GB × 4 scans × $1.00/TB  = $40.00
  BigQuery Storage:      ~$20.00 (scan results)
  BigQuery Queries:      ~$50.00 (scan execution)

  Total:                 ~$3,110.00/month
```

#### Example 2: Medium Deployment (50 tables, 500 GB each)

```
Assumptions:
  - 50 BigQuery tables
  - 500 GB per table = 25 TB total
  - Quality scans: Daily (30/month)
  - Profiling scans: Weekly (4/month)

Costs per month:
  Managed Storage:       $0.00 (FREE)
  Quality Scans:         50 tables × 500 GB × 30 scans × $0.10/GB = $75,000.00
  Profiling Scans:       50 tables × 500 GB × 4 scans × $1.00/TB  = $1,000.00
  BigQuery Storage:      ~$100.00 (scan results)
  BigQuery Queries:      ~$200.00 (scan execution)

  Total:                 ~$76,300.00/month
```

⚠️ **Important**: These are illustrative examples. Actual costs depend on:
- Table sizes
- Number of scans
- Scan frequency
- Number of columns scanned

---

## 9.2. Cost Optimization Strategies

### Strategy 1: Optimize Scan Frequency

```hcl
# ❌ BAD: Hourly scans (expensive)
schedule = "0 * * * *"  # 720 scans/month

# ✅ BETTER: Daily scans (24x cheaper)
schedule = "0 2 * * *"  # 30 scans/month

# ✅ BEST: Weekly scans for static tables (180x cheaper)
schedule = "0 2 * * 0"  # 4 scans/month
```

**Savings**: Up to **180x** cost reduction by changing from hourly to weekly scans

---

### Strategy 2: Scan Only Critical Columns

```hcl
# ❌ BAD: Scan all columns (expensive)
# Dataplex scans every column in the table

# ✅ BETTER: Scan only critical columns
quality_scans = [{
  rules = [
    { rule_type = "NON_NULL", column = "customer_id" },      # Critical
    { rule_type = "UNIQUENESS", column = "customer_id" },    # Critical
    { rule_type = "NON_NULL", column = "transaction_id" }    # Critical
    # Don't scan non-critical columns like "notes", "comments"
  ]
}]
```

**Savings**: Up to **50%** cost reduction by scanning only critical columns

---

### Strategy 3: Prioritize Tables for Scanning

```hcl
# ❌ BAD: Scan all tables equally
# Scan both critical production tables and test tables

# ✅ BETTER: Scan only critical production tables
quality_scans = [
  {
    scan_id = "critical-customer-quality"
    data_source = "...tables/customers"        # Critical
    schedule = "0 2 * * *"                     # Daily
  },
  {
    scan_id = "non-critical-logs-quality"
    data_source = "...tables/logs"             # Non-critical
    schedule = "0 2 * * 0"                     # Weekly (or skip)
  }
]
```

**Savings**: Up to **70%** cost reduction by not scanning non-critical tables

---

### Strategy 4: Use Incremental Scans (Future)

```hcl
# Currently, Dataplex scans full table each time
# Future: Incremental scans (only new/changed rows)

# When available:
quality_scans = [{
  scan_mode = "INCREMENTAL"  # Only scan new rows since last scan
  # Much cheaper for large, append-only tables
}]
```

---

### Strategy 5: Monitor and Budget

```bash
# Set up budget alerts
gcloud billing budgets create \
  --billing-account=BILLING_ACCOUNT \
  --display-name="Dataplex Budget" \
  --budget-amount=10000 \
  --threshold-rule=percent=50 \
  --threshold-rule=percent=80 \
  --threshold-rule=percent=100 \
  --all-updates-rule-pub sub-topic=projects/PROJECT/topics/budget-alerts

# Query costs
bq query --use_legacy_sql=false \
  'SELECT
     service.description,
     SUM(cost) as total_cost
   FROM `PROJECT.billing_export.gcp_billing_export_v1_XXXXX`
   WHERE service.description LIKE "%Dataplex%"
   AND _PARTITIONDATE >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
   GROUP BY service.description
   ORDER BY total_cost DESC'
```

---

## 9.3. Cost-Benefit Analysis

### Benefits (Quantified)

| Benefit | Baseline (without Dataplex) | With Dataplex | Improvement |
|---------|----------------------------|---------------|-------------|
| **Data Discovery Time** | 2 hours per analyst per week | 12 minutes | **10x faster** |
| **Data Quality Issues Detected** | After reports fail | Before deployment | **Early detection** |
| **Documentation Coverage** | 20% of data assets | 100% of data assets | **5x improvement** |
| **Compliance Audit Prep** | 40 hours per quarter | 4 hours per quarter | **10x faster** |

### Costs (Annual)

```
Estimated Annual Cost (Medium Deployment):
  - Dataplex: ~$76,300/month × 12 = ~$915,600/year

Cost Avoidance (Annual):
  - Analyst time saved: 100 analysts × 2 hours/week × $100/hour × 48 weeks = $960,000
  - Reduced report errors: Estimated $200,000/year in avoided business impact
  - Faster compliance audits: 140 hours/year × $150/hour = $21,000

  Total Cost Avoidance: ~$1,181,000/year

Net Benefit: ~$1,181,000 - $915,600 = ~$265,400/year (29% ROI)
```

**Note**: Cost-benefit analysis is illustrative. Actual ROI depends on organization size, data volumes, and use cases.

---

# 10. Appendices

## 10.1. Glossary of Terms

| Term | Definition |
|------|------------|
| **Asset** | A Dataplex resource that references a GCS bucket or BigQuery dataset |
| **Aspect Type** | Custom metadata fields that can be attached to catalog entries |
| **Catalog-Only Pattern** | Design where module only catalogs existing resources, doesn't create new ones |
| **CMEK** | Customer-Managed Encryption Keys (encryption keys managed by customer in Cloud KMS) |
| **CURATED Zone** | Dataplex zone for processed, structured data (requires Parquet/Avro/ORC for GCS, schema for BigQuery) |
| **Entry Group** | Logical grouping of catalog entries for organization |
| **Entry Type** | Template that defines the structure of catalog entries |
| **Glossary** | Collection of business terms and definitions |
| **ISS Foundation** | Infrastructure Self-Service Foundation (standardized GCP infrastructure framework) |
| **Lake** | Top-level organizational unit in Dataplex, contains zones |
| **Metadata** | Data about data (schema, statistics, descriptions), not the data itself |
| **Profiling Scan** | Statistical analysis of data (min, max, null%, distributions) |
| **Quality Scan** | Automated data quality validation (NON_NULL, UNIQUENESS, REGEX, RANGE, SET_MEMBERSHIP) |
| **RAW Zone** | Dataplex zone for unprocessed data (any format, any data) |
| **Zone** | Subdivision of a lake (RAW or CURATED) |

---

## 10.2. References

### Official Documentation

- [Google Cloud Dataplex](https://cloud.google.com/dataplex)
- [Dataplex Universal Catalog](https://cloud.google.com/dataplex/docs/universal-catalog)
- [Data Quality Overview](https://cloud.google.com/dataplex/docs/data-quality-overview)
- [Dataplex Quotas](https://cloud.google.com/dataplex/docs/quotas)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)

### Related Documentation

- [SECURITY_DISCOVERY.md](SECURITY_DISCOVERY.md) - Comprehensive security analysis
- [ISS_INTEGRATION.md](ISS_INTEGRATION.md) - Step-by-step ISS Foundation integration
- [README.md](../README.md) - User guide and examples

### Module Repository

- **GitHub**: [Dataplex Universal Catalog](https://github.com/Abhishek-Kraj/Dataplex-Universal-Catalog)
- **Branch**: `feature/iss-foundation` (catalog-only, ISS Foundation optimized)

---

## 10.3. Frequently Asked Questions (FAQ)

### Q1: Does Dataplex create GCS buckets or BigQuery datasets?

**A**: No. This module follows a **catalog-only pattern**. It only references existing GCS buckets and BigQuery datasets created by ISS Foundation built-in modules (`builtin_gcs_v2.tf`, `builtin_bigquery.tf`).

---

### Q2: How does encryption work?

**A**: All encryption is handled by **ISS Foundation**:
- GCS buckets: Encrypted with org-wide CMEK (automatically)
- BigQuery datasets: Encrypted with org-wide CMEK (automatically)
- Dataplex metadata: Encrypted by Google (Google-managed keys)
- Scan results: Stored in BigQuery, encrypted with org-wide CMEK

This module does NOT create or manage encryption keys.

---

### Q3: What permissions does the Dataplex service account need?

**A**: The Google-managed Dataplex service account (`service-{PROJECT_NUMBER}@gcp-sa-dataplex.iam.gserviceaccount.com`) needs:
- `roles/bigquery.dataViewer` - To read BigQuery data for quality scans
- `roles/storage.objectViewer` - To read GCS bucket metadata for asset discovery

These permissions are granted automatically by the module.

---

### Q4: Can I catalog resources in a different GCP project?

**A**: No. Dataplex assets must reference storage resources in the **same GCP project**. This is a Dataplex limitation. To catalog cross-project resources, deploy the module in each project separately.

---

### Q5: How much does Dataplex cost?

**A**:
- **Managed Storage** (lakes, zones, assets, entry groups): **FREE**
- **Data Quality Scans**: **$0.10 per 1 GB scanned**
- **Data Profiling**: **$1.00 per 1 TB scanned**
- **BigQuery Storage/Queries**: **Standard BigQuery pricing**

See [Cost Analysis](#9-cost-analysis) for detailed examples.

---

### Q6: How long does deployment take?

**A**: Typically **< 5 minutes** for initial deployment (via Terraform). Asset discovery (metadata indexing) can take up to **1 hour** after deployment.

---

### Q7: Can I use Dataplex with Datastream?

**A**: Yes! Dataplex integrates seamlessly with Datastream:
1. Datastream replicates data from Cloud SQL → BigQuery
2. Dataplex catalogs the BigQuery dataset created by Datastream
3. Dataplex runs quality scans on the replicated data

See [Use Case 4: Integration with Datastream](#use-case-4-integration-with-datastream-cdc-pipeline).

---

### Q8: What happens if I delete a Dataplex resource?

**A**: Deleting Dataplex resources (lakes, zones, assets, scans) does **NOT** affect underlying data:
- GCS buckets remain intact
- BigQuery datasets remain intact
- Only the Dataplex catalog metadata is deleted

You can recreate the catalog anytime by redeploying via Terraform.

---

### Q9: How do I rollback a deployment?

**A**:
```bash
# Option 1: Destroy all Dataplex resources
terraform destroy -target=module.project_dataplex

# Option 2: Restore previous Terraform state
terraform state pull > current.tfstate.backup
gsutil cp gs://terraform-state-bucket/previous.tfstate ./terraform.tfstate
terraform apply
```

See [Rollback Plan](#73-rollback-plan) for details.

---

### Q10: Do I need to create custom service accounts?

**A**: No. The module uses the **Google-managed Dataplex service account** (`service-{PROJECT_NUMBER}@gcp-sa-dataplex.iam.gserviceaccount.com`), which is created automatically when you enable the Dataplex API. No custom service accounts are needed.

---

## 10.4. Change Log

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| Jan 8, 2025 | 1.0 | Initial RFC document | Data Platform Team |

---

## 10.5. Approval Signatures

```
Security Team:
  Name: _______________________________
  Title: CISO / Security Architect
  Signature: _______________________________
  Date: _______________________________

Architecture Team:
  Name: _______________________________
  Title: Chief Architect / Solution Architect
  Signature: _______________________________
  Date: _______________________________

Compliance Team (if applicable):
  Name: _______________________________
  Title: Compliance Officer
  Signature: _______________________________
  Date: _______________________________

Business Owner:
  Name: _______________________________
  Title: Data Platform Lead / VP Engineering
  Signature: _______________________________
  Date: _______________________________
  Risk Acceptance: ☐ Accepted (Residual Risk: LOW)
```

---

## 10.6. Next Steps

After approval:

1. ✅ **Security team signs off** on security analysis
2. ✅ **Architecture team signs off** on technical design
3. ✅ **Compliance team signs off** (if applicable)
4. ✅ **Schedule implementation** (Weeks 1-6 per Implementation Plan)
5. ✅ **Deploy to sandbox** for testing
6. ✅ **Pilot deployment** to 1-2 non-production projects
7. ✅ **Production rollout** (phased approach)
8. ✅ **Operationalize** (monitoring, training, support)

---

**END OF RFC DOCUMENT**

**Document Status**: ☐ Draft | ☐ Under Review | ☐ Approved | ☐ Implemented

**Questions or Feedback?**
- Email: data-platform-team@company.com
- Slack: #data-platform
- GitHub Issues: [Dataplex Universal Catalog Issues](https://github.com/Abhishek-Kraj/Dataplex-Universal-Catalog/issues)

---

*This RFC is a living document and will be updated based on feedback and implementation learnings.*

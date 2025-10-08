# Security Discovery Document - Dataplex Universal Catalog Module

**Document Version:** 1.0
**Date:** 2025-01-08
**Module Version:** 2.0.0 (ISS Foundation Branch)
**Classification:** Internal - Security Review

---

## Executive Summary

This document provides a comprehensive security analysis of the Dataplex Universal Catalog Terraform module for security team review and approval. The module is designed to integrate with GCP ISS (Infrastructure Self-Service) Foundation and follows a **catalog-only** pattern that references existing storage resources without creating new infrastructure.

**Key Security Points:**
- ✅ **No storage creation** - Module only catalogs existing resources
- ✅ **No encryption management** - ISS Foundation handles org-wide KMS encryption
- ✅ **No IAM policy creation** - Uses existing Google-managed service accounts
- ✅ **Read-only cataloging** - Does not modify or access data content
- ✅ **Audit logging enabled** - All operations logged via Cloud Audit Logs

---

## Table of Contents

1. [Module Overview](#module-overview)
2. [Security Architecture](#security-architecture)
3. [Data Security](#data-security)
4. [Access Control & IAM](#access-control--iam)
5. [Encryption](#encryption)
6. [Network Security](#network-security)
7. [Audit & Compliance](#audit--compliance)
8. [Service Accounts](#service-accounts)
9. [API Permissions Required](#api-permissions-required)
10. [Data Privacy & PII](#data-privacy--pii)
11. [Threat Model](#threat-model)
12. [Security Best Practices](#security-best-practices)
13. [Compliance & Standards](#compliance--standards)
14. [Risk Assessment](#risk-assessment)
15. [Security Controls](#security-controls)
16. [Incident Response](#incident-response)
17. [Security Testing](#security-testing)
18. [Approval Checklist](#approval-checklist)

---

## Module Overview

### Purpose
The Dataplex Universal Catalog module provides metadata cataloging and data governance for existing GCS buckets and BigQuery datasets within GCP ISS Foundation.

### What the Module Does
- ✅ Creates Dataplex lakes, zones, and assets (metadata only)
- ✅ Catalogs existing storage resources (GCS buckets, BigQuery datasets)
- ✅ Enables data quality scans and profiling
- ✅ Creates business glossaries for data governance
- ✅ Provides metadata search and discovery

### What the Module Does NOT Do
- ❌ Create GCS buckets or BigQuery datasets
- ❌ Manage KMS encryption keys
- ❌ Create or manage service accounts
- ❌ Access, read, or modify actual data content
- ❌ Create VPC networks or firewall rules
- ❌ Handle data ingestion or ETL processes
- ❌ Manage IAM policies outside Dataplex scope

### Deployment Model
```
ISS Foundation → Creates Storage (encrypted) → Dataplex Module → Catalogs Metadata
```

---

## Security Architecture

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│ GCP ISS Foundation (Organization Level)                         │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Org-wide KMS Encryption                                   │  │
│  │ local.encryption.encryption_symmetric_keys                │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ builtin_gcs_v2.tf                                         │  │
│  │ Creates GCS buckets with:                                 │  │
│  │ - Org-wide KMS encryption (automatic)                     │  │
│  │ - Uniform bucket-level access                             │  │
│  │ - Versioning (if enabled)                                 │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ builtin_bigquery.tf                                       │  │
│  │ Creates BigQuery datasets with:                           │  │
│  │ - Org-wide KMS encryption (automatic)                     │  │
│  │ - Dataset-level access controls                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ Dataplex Module (Catalog Only)                                  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Dataplex Lakes & Zones                                    │  │
│  │ - Logical organization (metadata only)                    │  │
│  │ - No data access or modification                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Dataplex Assets                                           │  │
│  │ - References existing buckets/datasets                    │  │
│  │ - Discovery and indexing (metadata only)                  │  │
│  │ - No encryption management                                │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Data Quality Scans                                        │  │
│  │ - Validation rules (NON_NULL, UNIQUENESS, etc.)           │  │
│  │ - Uses Google-managed Dataplex SA                         │  │
│  │ - Results stored in BigQuery (encrypted)                  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Metadata Catalog                                          │  │
│  │ - Entry groups, types, aspect types                       │  │
│  │ - Business glossaries (BigQuery tables)                   │  │
│  │ - Searchable via Data Catalog API                         │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ Cloud Audit Logs                                                 │
│ - All Dataplex API calls logged                                  │
│ - Admin activity logs (always on)                                │
│ - Data access logs (if enabled)                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Security Boundaries

1. **Organization Boundary**: ISS Foundation manages org-wide policies
2. **Project Boundary**: Each project isolated with separate resources
3. **Resource Boundary**: Dataplex assets reference but don't access data
4. **API Boundary**: All access through GCP APIs with audit logging

---

## Data Security

### Data at Rest

#### Storage Encryption
- **GCS Buckets**: Encrypted by ISS Foundation using org-wide CMEK (Customer-Managed Encryption Keys)
- **BigQuery Datasets**: Encrypted by ISS Foundation using org-wide CMEK
- **Dataplex Metadata**: Encrypted by Google using Google-managed keys
- **Scan Results**: Stored in BigQuery with org-wide CMEK encryption

#### Encryption Key Management
```
ISS Foundation manages:
├── Organization-level KMS keyring
├── Regional encryption keys
├── Key rotation policies (automatic 90 days)
└── Key access controls (IAM)

Dataplex module:
├── Does NOT create KMS keys
├── Does NOT manage encryption
└── Inherits encryption from underlying storage
```

#### Data Classification Support
The module supports data classification through:
- Custom aspect types with PII/sensitivity fields
- Entry-level metadata tags
- Business glossary terms for data definitions
- No actual data content is accessed or classified by the module

### Data in Transit

- **API Communication**: All GCP API calls use TLS 1.2+ (Google-managed)
- **Internal Google Network**: Traffic stays within Google's private network
- **No External Endpoints**: Module creates no public-facing endpoints
- **VPC Service Controls**: Compatible with VPC-SC perimeters (if configured at org level)

### Data Access

**Critical Security Point**: This module does **NOT** access actual data content.

```
┌─────────────────────────────────────────────────────────┐
│ What Dataplex Module Accesses                           │
├─────────────────────────────────────────────────────────┤
│ ✅ Bucket/dataset names (metadata)                       │
│ ✅ Schema information (structure only)                   │
│ ✅ Table/file statistics (row counts, sizes)             │
│ ✅ Column names and data types                           │
│                                                          │
│ ❌ Actual data values (rows, records, files)             │
│ ❌ PII or sensitive content                              │
│ ❌ Business data                                         │
└─────────────────────────────────────────────────────────┘
```

**Exception**: Data Quality Scans
- Quality scans (NON_NULL, UNIQUENESS, etc.) read data values for validation
- Scan results contain statistics, NOT actual data values
- Scans run using Google-managed Dataplex service account
- Results stored in encrypted BigQuery tables

---

## Access Control & IAM

### Required Permissions (Terraform Deployment)

The Terraform service account requires these permissions:

```yaml
# Dataplex Permissions
- dataplex.lakes.create
- dataplex.lakes.update
- dataplex.lakes.delete
- dataplex.zones.create
- dataplex.zones.update
- dataplex.zones.delete
- dataplex.assets.create
- dataplex.assets.update
- dataplex.assets.delete
- dataplex.datascans.create
- dataplex.datascans.update
- dataplex.datascans.delete

# Data Catalog Permissions
- datacatalog.entryGroups.create
- datacatalog.entryGroups.update
- datacatalog.entryGroups.delete
- datacatalog.entries.create
- datacatalog.entries.update
- datacatalog.entries.delete

# BigQuery Permissions (for glossaries and scan results)
- bigquery.datasets.create
- bigquery.datasets.get
- bigquery.tables.create
- bigquery.tables.get
- bigquery.tables.update

# Storage Permissions (read-only, for asset discovery)
- storage.buckets.get
- storage.buckets.list
```

**Recommended IAM Roles:**
```bash
roles/dataplex.admin          # Dataplex resource management
roles/datacatalog.admin       # Catalog management
roles/bigquery.dataEditor     # For glossary tables
roles/storage.objectViewer    # For bucket metadata (read-only)
```

### Runtime Service Accounts

#### Google-Managed Dataplex Service Account
```
service-{PROJECT_NUMBER}@gcp-sa-dataplex.iam.gserviceaccount.com
```

**Created automatically by Google when Dataplex API is enabled.**

**Permissions granted by this module:**
- `roles/dataplex.viewer` - Read access to Dataplex resources (if IAM binding configured)
- `roles/bigquery.dataViewer` - Read BigQuery data for quality scans
- `roles/storage.objectViewer` - Read GCS bucket metadata

**Security Note**: This service account is managed by Google, not by users. Google controls its lifecycle and security.

#### Custom Service Accounts (NOT Used in ISS Foundation)

In ISS Foundation deployment:
- `enable_secure = false` - Module does NOT create custom service accounts
- Uses Google-managed Dataplex SA only
- Follows ISS Foundation pattern

### Principle of Least Privilege

```
┌────────────────────────────────────────────────────────┐
│ Access Level          │ Granted To      │ Scope        │
├────────────────────────────────────────────────────────┤
│ Terraform Deployment  │ Terraform SA    │ Project      │
│ - Create/Update/Delete Dataplex resources               │
│ - Read storage metadata (buckets, datasets)             │
│                                                         │
│ Runtime Operations    │ Dataplex SA     │ Project      │
│ - Discover and index assets                            │
│ - Run quality/profiling scans                          │
│ - Write scan results to BigQuery                       │
│                                                         │
│ End Users             │ User/Group      │ Lake-level   │
│ - View catalog (roles/dataplex.viewer)                 │
│ - Search metadata                                      │
│ - View quality reports                                 │
└────────────────────────────────────────────────────────┘
```

### IAM Binding Configuration (Optional)

```hcl
# Example: Grant analysts view access to Dataplex lake
iam_bindings = [
  {
    lake_id = "analytics-lake"
    role    = "roles/dataplex.viewer"
    members = [
      "group:data-analysts@company.com"
    ]
  }
]
```

**Security Implications:**
- `roles/dataplex.viewer` grants read-only access to Dataplex metadata
- Does NOT grant access to underlying data (bucket/dataset IAM controls that)
- Follows IAM inheritance model

---

## Encryption

### Encryption Summary

| Resource Type | Encryption Method | Key Management | Module Involvement |
|---------------|-------------------|----------------|-------------------|
| **GCS Buckets** | CMEK (Customer-Managed) | ISS Foundation org-wide KMS | ❌ None - references only |
| **BigQuery Datasets** | CMEK (Customer-Managed) | ISS Foundation org-wide KMS | ❌ None - references only |
| **Dataplex Metadata** | Google-managed | Google | ❌ None - automatic |
| **Scan Results (BQ)** | CMEK (Customer-Managed) | ISS Foundation org-wide KMS | ❌ None - inherits from project |
| **Glossary Tables (BQ)** | CMEK (Customer-Managed) | ISS Foundation org-wide KMS | ✅ Creates tables (encrypted) |

### Encryption Key Hierarchy (ISS Foundation)

```
Organization
  └── KMS Keyring (per region)
        ├── Encryption Key (symmetric)
        │     ├── Automatic rotation: 90 days
        │     ├── Access: restricted to approved SAs
        │     └── Audit: all key usage logged
        │
        └── Used by:
              ├── builtin_gcs_v2.tf (buckets)
              ├── builtin_bigquery.tf (datasets)
              └── All BQ tables (including Dataplex scan results)
```

### Encryption Validation

**Security team can validate:**

```bash
# Check bucket encryption
gsutil kms encryption gs://{BUCKET_NAME}

# Expected output:
# projects/{PROJECT}/locations/{REGION}/keyRings/{KEYRING}/cryptoKeys/{KEY}

# Check BigQuery dataset encryption
bq show --format=prettyjson {PROJECT}:{DATASET}

# Expected: "defaultEncryptionConfiguration": {
#   "kmsKeyName": "projects/{PROJECT}/locations/{REGION}/..."
# }
```

### Key Rotation

- **Automatic rotation**: Configured at org level (typically 90 days)
- **Manual rotation**: Supported through ISS Foundation KMS management
- **Module impact**: None - module doesn't manage keys

---

## Network Security

### Network Architecture

**Important**: Dataplex is a **serverless, fully-managed** GCP service.

```
┌─────────────────────────────────────────────────────────┐
│ Network Characteristics                                  │
├─────────────────────────────────────────────────────────┤
│ ❌ No VMs deployed                                       │
│ ❌ No customer-managed networks                          │
│ ❌ No public IP addresses                                │
│ ❌ No firewall rules to configure                        │
│ ✅ All traffic within Google private network             │
│ ✅ API access via private Google endpoints               │
└─────────────────────────────────────────────────────────┘
```

### VPC Service Controls (VPC-SC) Support

Dataplex is compatible with VPC Service Controls:

```
┌─────────────────────────────────────────────────────────┐
│ VPC-SC Perimeter                                         │
│                                                          │
│  ┌────────────────────────────────────────────────┐    │
│  │ Protected Project                               │    │
│  │                                                 │    │
│  │  • GCS Buckets (within perimeter)              │    │
│  │  • BigQuery Datasets (within perimeter)        │    │
│  │  • Dataplex Resources (within perimeter)       │    │
│  │                                                 │    │
│  │  Access from outside perimeter: BLOCKED         │    │
│  └────────────────────────────────────────────────┘    │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

**Configuration**: VPC-SC is configured at organization/project level, not by this module.

### Private Google Access

- All API communication uses Google's private network
- No internet egress required
- Compatible with Private Google Access for on-premises connectivity

### Firewall & Network Policies

**Not Applicable**: Dataplex is serverless - no firewall rules needed.

---

## Audit & Compliance

### Cloud Audit Logs

#### Admin Activity Logs (Always Enabled)

```yaml
# Logged automatically, cannot be disabled
- dataplex.lakes.create
- dataplex.lakes.update
- dataplex.lakes.delete
- dataplex.zones.create
- dataplex.assets.create
- dataplex.datascans.create
- datacatalog.entryGroups.create
# ... all administrative operations
```

**Log Retention**: 400 days (default, configurable)

#### Data Access Logs (Optional)

```yaml
# Must be explicitly enabled at project/folder/org level
- dataplex.assets.list
- dataplex.lakes.get
- datacatalog.entries.list
- Search API calls
```

**Security Recommendation**: Enable data access logs for sensitive environments.

#### Audit Log Example

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
      "lakeId": "analytics-lake"
    }
  },
  "insertId": "...",
  "resource": {
    "type": "dataplex.googleapis.com/Lake",
    "labels": {
      "project_id": "project-id",
      "location": "us-central1"
    }
  },
  "timestamp": "2025-01-08T10:00:00Z",
  "severity": "NOTICE"
}
```

### Log Monitoring & Alerting

**Recommended Log-based Metrics:**

```yaml
# Failed authentication attempts
resource.type="dataplex.googleapis.com/Lake"
protoPayload.status.code!=0

# Unauthorized access attempts
resource.type="dataplex.googleapis.com/Lake"
protoPayload.status.code=7

# Asset deletion (critical operation)
protoPayload.methodName="google.cloud.dataplex.v1.DataplexService.DeleteAsset"

# Quality scan failures
resource.type="dataplex.googleapis.com/DataScan"
protoPayload.status.code!=0
```

### Compliance Frameworks

#### SOC 2 Type II
- ✅ Audit logging enabled
- ✅ Access controls (IAM)
- ✅ Encryption at rest (CMEK)
- ✅ Encryption in transit (TLS 1.2+)
- ✅ Regular security assessments (Google SRE)

#### ISO 27001
- ✅ Information security management
- ✅ Access control (principle of least privilege)
- ✅ Cryptography (CMEK, TLS)
- ✅ Operations security (audit logs)

#### GDPR
- ✅ Data encryption (CMEK)
- ✅ Access logging (audit trails)
- ✅ Data residency (regional deployment)
- ⚠️ PII handling: Module catalogs metadata only, not PII content
- ⚠️ Right to deletion: Must delete Dataplex assets when underlying data is deleted

#### HIPAA (if applicable)
- ✅ GCP Dataplex is HIPAA compliant (when BAA signed with Google)
- ✅ Encryption at rest and in transit
- ✅ Audit logging
- ⚠️ Quality scans on PHI: Review scan configurations carefully

#### PCI-DSS (if applicable)
- ✅ Encryption of cardholder data (via CMEK)
- ✅ Access controls and audit trails
- ⚠️ Cardholder data: Module should only catalog metadata, not card data

### Compliance Controls Matrix

| Control | Requirement | Implementation | Module Role |
|---------|-------------|----------------|-------------|
| **Encryption** | Data encrypted at rest | CMEK via ISS Foundation | ❌ None |
| **Access Control** | Least privilege IAM | Role-based access | ✅ Configurable IAM bindings |
| **Audit Logging** | All access logged | Cloud Audit Logs | ✅ Automatic |
| **Data Residency** | Regional storage | GCP regions | ✅ Configurable location |
| **Vulnerability Mgmt** | Regular scanning | Google SRE + Security Command Center | ❌ Google-managed |
| **Incident Response** | Log monitoring | Cloud Logging + Monitoring | ✅ Logs available |

---

## Service Accounts

### Google-Managed Dataplex Service Account

**Automatically created**: `service-{PROJECT_NUMBER}@gcp-sa-dataplex.iam.gserviceaccount.com`

**Lifecycle**:
- Created when Dataplex API is enabled
- Managed by Google (cannot be deleted by users)
- No key rotation required (Google-managed)

**Permissions**:
```
Default permissions (Google-managed):
├── Internal Dataplex operations
├── Metadata discovery
└── Asset indexing

User-granted permissions (via module):
├── roles/bigquery.dataViewer (for quality scans)
└── roles/storage.objectViewer (for bucket discovery)
```

**Security Controls**:
- Cannot be impersonated by users
- No exportable keys
- Audit logs track all operations
- Managed by Google's security team

### Terraform Service Account

**Required for deployment**: Custom SA or user account with appropriate roles.

**Recommended Configuration**:
```hcl
# Create dedicated Terraform SA
resource "google_service_account" "terraform" {
  account_id   = "terraform-dataplex"
  display_name = "Terraform - Dataplex Deployment"
  description  = "Service account for deploying Dataplex resources"
}

# Grant minimum required permissions
resource "google_project_iam_member" "terraform_dataplex" {
  project = var.project_id
  role    = "roles/dataplex.admin"
  member  = "serviceAccount:${google_service_account.terraform.email}"
}
```

**Security Best Practices**:
- ✅ Use short-lived credentials (Workload Identity, OIDC)
- ✅ Rotate keys regularly (if using key-based auth)
- ✅ Store keys in Secret Manager (never in Git)
- ✅ Enable constraints/iam.disableServiceAccountKeyCreation (org policy)
- ✅ Monitor SA activity via audit logs

### Service Account Security Summary

| Service Account Type | Purpose | Key Management | Scope |
|---------------------|---------|----------------|-------|
| **Google-managed Dataplex SA** | Runtime operations | Google-managed (no keys) | Project |
| **Terraform SA** | Deployment | User-managed (prefer keyless) | Project |
| **Custom SAs** | NOT used in ISS Foundation | N/A | N/A |

---

## API Permissions Required

### GCP APIs Enabled

```yaml
Required APIs:
  - dataplex.googleapis.com          # Dataplex service
  - datacatalog.googleapis.com       # Data Catalog
  - bigquery.googleapis.com          # BigQuery (for glossaries, scan results)
  - storage-api.googleapis.com       # Cloud Storage (for bucket discovery)
  - cloudresourcemanager.googleapis.com  # Project management
  - serviceusage.googleapis.com      # API management
  - iam.googleapis.com              # IAM operations

Optional APIs:
  - monitoring.googleapis.com        # Cloud Monitoring (if enable_monitoring=true)
  - logging.googleapis.com          # Cloud Logging
```

### API Security Controls

```
API Access Controls:
├── API key restrictions (if used)
│   ├── Restrict to specific APIs
│   ├── Restrict by IP address
│   └── Restrict by HTTP referrer
│
├── Service account authentication (recommended)
│   ├── OAuth 2.0 tokens
│   ├── Short-lived credentials
│   └── No long-term keys
│
└── VPC Service Controls (if configured)
    ├── Restrict API access to VPC-SC perimeter
    └── Block exfiltration attempts
```

### API Rate Limits & Quotas

See [Module README - Quotas and Limits](../README.md#quotas-and-limits)

**Security Implication**: Rate limits prevent abuse and DoS attacks.

---

## Data Privacy & PII

### Personal Identifiable Information (PII) Handling

**Critical Understanding**: This module **does NOT access or process PII content**.

```
┌─────────────────────────────────────────────────────────┐
│ PII Handling Matrix                                      │
├─────────────────────────────────────────────────────────┤
│ Module Activity          │ PII Access?  │ Risk Level    │
├─────────────────────────────────────────────────────────┤
│ Creating Dataplex lakes  │ ❌ No        │ None          │
│ Creating zones/assets    │ ❌ No        │ None          │
│ Discovering table schema │ ❌ No        │ Low (metadata)│
│ Quality scans (stats)    │ ⚠️  Yes*     │ Medium**      │
│ Profiling scans          │ ⚠️  Yes*     │ Medium**      │
│ Business glossaries      │ ❌ No        │ None          │
│ Metadata search          │ ❌ No        │ None          │
└─────────────────────────────────────────────────────────┘

* Quality/profiling scans read data values for analysis
** Scan results contain STATISTICS, not actual PII values
```

### Quality Scan PII Considerations

**Example: Email validation scan**

```hcl
# This scan checks if emails match regex pattern
quality_scans = [{
  rules = [{
    rule_type = "REGEX"
    column    = "email"
    pattern   = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
    threshold = 0.95
  }]
}]
```

**What gets stored in scan results:**
```json
{
  "rule": "REGEX on column 'email'",
  "passed_count": 950,
  "failed_count": 50,
  "total_rows": 1000,
  "pass_percentage": 95.0,
  "failed_records_sample": 5  // Sample count, not actual emails
}
```

**PII Protection:**
- ✅ Scan results DO NOT contain actual PII values
- ✅ Only aggregate statistics are stored
- ✅ Failed record samples are counts, not content
- ⚠️ Column names may indicate PII fields (e.g., "email", "ssn")

### Data Residency

```hcl
# Control data location
location = "us-central1"  # All Dataplex metadata stays in this region
```

**Supported Regions**: All GCP regions where Dataplex is available.

**Multi-region Consideration**:
- BigQuery datasets can be multi-region (e.g., "US", "EU")
- Dataplex metadata follows the specified `location` parameter
- Scan results stored in BigQuery inherit dataset's location/encryption

### GDPR Right to Erasure

**If underlying data is deleted:**

1. **Automatic**: Dataplex asset discovery will mark resource as unavailable
2. **Manual**: Delete Dataplex asset via Terraform (`terraform destroy` specific resource)
3. **Glossary terms**: Manually delete if they reference the deleted entity

**Example: Deleting an asset**
```bash
# Via Terraform
terraform destroy -target=module.dataplex.google_dataplex_asset.bigquery_assets[\"lake-id:zone-id\"]

# Via gcloud
gcloud dataplex assets delete {ASSET_ID} \
  --location={LOCATION} \
  --lake={LAKE_ID} \
  --zone={ZONE_ID}
```

---

## Threat Model

### Threat Analysis

#### Threat 1: Unauthorized Access to Metadata

**Threat**: Attacker gains access to Dataplex catalog and discovers sensitive data locations.

**Likelihood**: Low
**Impact**: Medium
**Mitigation**:
- ✅ IAM controls (principle of least privilege)
- ✅ Audit logging tracks all access
- ✅ VPC-SC restricts API access to authorized networks
- ✅ Regular IAM reviews

#### Threat 2: Data Exfiltration via Quality Scans

**Threat**: Attacker uses quality scans to read sensitive data.

**Likelihood**: Low
**Impact**: High
**Mitigation**:
- ✅ Dataplex SA has minimal permissions (read-only)
- ✅ Scan results contain statistics, not raw data
- ✅ Audit logs track all scan operations
- ✅ IAM controls who can create scans
- ⚠️ Security team should review scan configurations on sensitive data

#### Threat 3: Privilege Escalation via Service Account

**Threat**: Attacker compromises Terraform SA and creates malicious Dataplex resources.

**Likelihood**: Low
**Impact**: Medium
**Mitigation**:
- ✅ Use short-lived credentials (Workload Identity)
- ✅ Audit logs track all SA operations
- ✅ Terraform SA has limited scope (Dataplex only)
- ✅ No ability to modify underlying data
- ✅ Separation of duties (Terraform SA != Data SA)

#### Threat 4: Metadata Tampering

**Threat**: Attacker modifies business glossary or metadata to hide malicious activity.

**Likelihood**: Low
**Impact**: Low
**Mitigation**:
- ✅ Audit logs track all metadata changes
- ✅ IAM controls write access
- ✅ Infrastructure-as-Code tracks changes via Git
- ✅ Terraform state shows resource drift

#### Threat 5: Denial of Service via API Abuse

**Threat**: Attacker floods Dataplex APIs to cause service disruption.

**Likelihood**: Very Low
**Impact**: Low
**Mitigation**:
- ✅ GCP API rate limits and quotas
- ✅ Monitoring alerts on quota exhaustion
- ✅ Google's DDoS protection
- ✅ VPC-SC restricts API access

#### Threat 6: Insider Threat - Malicious Admin

**Threat**: Malicious administrator with Dataplex admin access deletes critical catalog.

**Likelihood**: Very Low
**Impact**: Medium
**Mitigation**:
- ✅ Audit logs track all administrative actions
- ✅ Infrastructure-as-Code enables quick restoration
- ✅ Terraform state backups in Cloud Storage
- ✅ Separation of duties (read vs. write access)
- ✅ Multi-person approval for production changes

### Threat Model Summary

| Threat | Likelihood | Impact | Risk Score | Mitigation Status |
|--------|-----------|--------|------------|-------------------|
| Unauthorized metadata access | Low | Medium | **Medium** | ✅ Mitigated |
| Data exfiltration via scans | Low | High | **Medium** | ✅ Mitigated |
| Privilege escalation | Low | Medium | **Medium** | ✅ Mitigated |
| Metadata tampering | Low | Low | **Low** | ✅ Mitigated |
| API DoS | Very Low | Low | **Low** | ✅ Mitigated |
| Insider threat | Very Low | Medium | **Low** | ✅ Mitigated |

**Overall Risk Assessment**: **LOW to MEDIUM**

---

## Security Best Practices

### Deployment Security

1. **Use Infrastructure-as-Code**
   ```bash
   ✅ All resources defined in Terraform
   ✅ Changes tracked in Git
   ✅ Peer review required before merge
   ✅ Automated CI/CD pipeline with security checks
   ```

2. **Secure Terraform State**
   ```hcl
   terraform {
     backend "gcs" {
       bucket         = "terraform-state-bucket"
       prefix         = "dataplex"
       encryption_key = "projects/{PROJECT}/locations/{REGION}/keyRings/{KEYRING}/cryptoKeys/{KEY}"
     }
   }
   ```

3. **Use Service Account Impersonation**
   ```bash
   # Don't use long-term keys
   gcloud config set auth/impersonate_service_account terraform-sa@project.iam.gserviceaccount.com
   terraform apply
   ```

### Runtime Security

1. **Enable Data Access Logs**
   ```bash
   gcloud logging sinks create dataplex-access-logs \
     bigquery.googleapis.com/projects/{PROJECT}/datasets/audit_logs \
     --log-filter='resource.type="dataplex.googleapis.com/Lake"'
   ```

2. **Monitor Quality Scan Configurations**
   ```bash
   # Alert on scans targeting sensitive tables
   protoPayload.methodName="google.cloud.dataplex.v1.DataScanService.CreateDataScan"
   AND protoPayload.request.dataSource=~"sensitive_dataset"
   ```

3. **Regular IAM Reviews**
   ```bash
   # List all IAM bindings on Dataplex resources
   gcloud dataplex lakes get-iam-policy {LAKE_ID} --location={LOCATION}

   # Review monthly, remove unnecessary access
   ```

### Data Governance Security

1. **Classify Data Assets**
   ```hcl
   # Use aspect types to classify sensitivity
   aspect_types = [{
     aspect_type_id = "data-classification"
     metadata_template = {
       fields = [{
         field_id = "sensitivity"
         type     = "ENUM"
         enum_values = ["PUBLIC", "INTERNAL", "CONFIDENTIAL", "RESTRICTED"]
       }]
     }
   }]
   ```

2. **Limit Quality Scans on Sensitive Data**
   ```hcl
   # Only run non-intrusive scans on PII columns
   quality_scans = [{
     rules = [
       { rule_type = "NON_NULL", column = "customer_id" },  # ✅ Safe
       # Avoid REGEX on PII columns unless necessary
     ]
   }]
   ```

3. **Use Business Glossaries for Data Ownership**
   ```hcl
   glossaries = [{
     terms = [{
       term_id     = "customer_data"
       description = "Owner: Data Privacy Team | Classification: CONFIDENTIAL"
     }]
   }]
   ```

### Network Security (VPC-SC)

1. **Create VPC Service Controls Perimeter**
   ```bash
   gcloud access-context-manager perimeters create dataplex_perimeter \
     --resources=projects/{PROJECT_NUMBER} \
     --restricted-services=dataplex.googleapis.com,datacatalog.googleapis.com \
     --policy={POLICY_ID}
   ```

2. **Whitelist Authorized Networks**
   ```yaml
   # Only allow Terraform from corporate network
   ingressPolicies:
     - ingressFrom:
         sources:
           - accessLevel: corporate_network
         identities:
           - serviceAccount:terraform-sa@project.iam.gserviceaccount.com
   ```

---

## Compliance & Standards

### Certifications & Attestations

GCP Dataplex holds the following certifications:

- ✅ **ISO 27001** - Information security management
- ✅ **ISO 27017** - Cloud security
- ✅ **ISO 27018** - Personal data protection in cloud
- ✅ **SOC 2 Type II** - Security, availability, confidentiality
- ✅ **SOC 3** - General controls report
- ✅ **PCI-DSS** - Payment card industry (with conditions)
- ✅ **HIPAA** - Healthcare (with BAA)
- ✅ **FedRAMP** - US government (Moderate impact level)
- ✅ **GDPR** - EU data protection

**Reference**: [GCP Compliance Offerings](https://cloud.google.com/security/compliance/offerings)

### Industry Standards Alignment

#### NIST Cybersecurity Framework

| Category | NIST Function | Dataplex Implementation |
|----------|---------------|-------------------------|
| **Identify** | Asset Management | ✅ Automated discovery and cataloging |
| **Protect** | Access Control | ✅ IAM with least privilege |
| **Protect** | Data Security | ✅ CMEK encryption via ISS Foundation |
| **Detect** | Monitoring | ✅ Cloud Audit Logs, quality scans |
| **Respond** | Analysis | ✅ Log analytics, alerting |
| **Recover** | Recovery Planning | ✅ Infrastructure-as-Code for rapid restore |

#### CIS Google Cloud Platform Foundation Benchmark

| CIS Control | Requirement | Implementation |
|-------------|-------------|----------------|
| 1.4 | Ensure KMS encryption keys are rotated | ✅ ISS Foundation handles |
| 1.15 | Ensure API keys are restricted | ✅ Recommend SA authentication |
| 2.1 | Ensure Cloud Audit Logging is configured | ✅ Enabled by default |
| 2.3 | Ensure log metric filter and alerts exist | ⚠️ Customer responsibility |
| 3.1 | Ensure default network does not exist | ✅ N/A (serverless) |
| 6.2.1 | Ensure VPC Flow Logs is enabled | ✅ N/A (serverless) |

### Regulatory Compliance Mapping

#### GDPR Articles

| Article | Requirement | Dataplex Capability |
|---------|-------------|---------------------|
| Art. 25 | Data protection by design | ✅ Metadata-only architecture |
| Art. 30 | Records of processing | ✅ Audit logs |
| Art. 32 | Security of processing | ✅ Encryption, access controls |
| Art. 33 | Breach notification | ⚠️ Use Cloud Logging alerts |
| Art. 35 | Data protection impact assessment | ✅ This document serves as DPIA input |

#### HIPAA Requirements (if applicable)

| HIPAA Rule | Requirement | Implementation |
|------------|-------------|----------------|
| § 164.308(a)(1) | Security Management | ✅ IAM, audit logs |
| § 164.308(a)(3) | Workforce Security | ✅ Role-based access |
| § 164.312(a)(1) | Access Control | ✅ IAM policies |
| § 164.312(a)(2)(iv) | Encryption | ✅ CMEK (ISS Foundation) |
| § 164.312(b) | Audit Controls | ✅ Cloud Audit Logs |

**Note**: Requires Business Associate Agreement (BAA) with Google.

---

## Risk Assessment

### Risk Register

| Risk ID | Risk Description | Likelihood | Impact | Inherent Risk | Residual Risk (with controls) |
|---------|------------------|-----------|--------|---------------|-------------------------------|
| **R1** | Unauthorized access to sensitive metadata | Medium | Medium | **MEDIUM** | **LOW** |
| **R2** | Data exfiltration via quality scans | Low | High | **MEDIUM** | **LOW** |
| **R3** | Service account compromise | Low | Medium | **MEDIUM** | **LOW** |
| **R4** | Accidental deletion of catalog | Low | Low | **LOW** | **VERY LOW** |
| **R5** | Compliance violation (GDPR, HIPAA) | Low | High | **MEDIUM** | **LOW** |
| **R6** | API quota exhaustion (DoS) | Very Low | Low | **LOW** | **VERY LOW** |

### Risk Matrix

```
Impact →
         Low         Medium      High
      ┌──────────┬──────────┬──────────┐
High  │          │          │          │
      │   LOW    │  MEDIUM  │   HIGH   │
      ├──────────┼──────────┼──────────┤
Med   │          │    R1    │    R2    │
      │VERY LOW  │    R3    │    R5    │
      ├──────────┼──────────┼──────────┤
Low   │    R4    │          │          │
      │    R6    │   LOW    │  MEDIUM  │
      └──────────┴──────────┴──────────┘
↑
Likelihood
```

**Overall Risk Level**: **LOW** (with controls implemented)

### Risk Mitigation Plan

#### R1: Unauthorized Access to Sensitive Metadata
**Controls**:
- Implement least privilege IAM
- Enable data access audit logs
- Quarterly IAM access reviews
- VPC Service Controls for sensitive projects

**Residual Risk**: LOW

#### R2: Data Exfiltration via Quality Scans
**Controls**:
- Restrict `dataplex.datascans.create` permission
- Review scan configurations on sensitive tables
- Monitor audit logs for unusual scan activity
- Scan results contain statistics only (not raw data)

**Residual Risk**: LOW

#### R3: Service Account Compromise
**Controls**:
- Use Workload Identity (no long-term keys)
- Enable constraints/iam.disableServiceAccountKeyCreation
- Monitor SA activity via audit logs
- Separate Terraform SA from runtime SAs

**Residual Risk**: LOW

#### R4: Accidental Deletion of Catalog
**Controls**:
- Infrastructure-as-Code (can recreate)
- Terraform state backed up to Cloud Storage
- Require peer review for production changes
- Enable deletion protection on critical resources

**Residual Risk**: VERY LOW

#### R5: Compliance Violation
**Controls**:
- Follow ISS Foundation encryption standards
- Enable audit logging
- Document data classification in glossaries
- Regular compliance audits

**Residual Risk**: LOW

#### R6: API Quota Exhaustion
**Controls**:
- GCP quota limits prevent abuse
- Monitor API usage metrics
- Alerting on quota thresholds (80%)

**Residual Risk**: VERY LOW

---

## Security Controls

### Preventive Controls

| Control ID | Control Description | Implementation | Status |
|------------|---------------------|----------------|--------|
| **PC-01** | Encryption at rest (CMEK) | ISS Foundation KMS | ✅ Implemented |
| **PC-02** | Encryption in transit (TLS 1.2+) | Google-managed | ✅ Implemented |
| **PC-03** | Least privilege IAM | Role-based access | ✅ Implemented |
| **PC-04** | VPC Service Controls | Optional (org-level) | ⚠️ Recommended |
| **PC-05** | API key restrictions | Service account auth | ✅ Recommended |
| **PC-06** | Service account key constraints | Org policy | ✅ Recommended |
| **PC-07** | No public endpoints | Serverless architecture | ✅ Implemented |

### Detective Controls

| Control ID | Control Description | Implementation | Status |
|------------|---------------------|----------------|--------|
| **DC-01** | Cloud Audit Logs (admin) | Automatic | ✅ Implemented |
| **DC-02** | Cloud Audit Logs (data access) | Optional | ⚠️ Recommended |
| **DC-03** | Log-based metrics | Customer-configured | ⚠️ Recommended |
| **DC-04** | Alerting on suspicious activity | Customer-configured | ⚠️ Recommended |
| **DC-05** | Security Command Center | Automatic findings | ✅ Available |
| **DC-06** | IAM recommender | Automatic suggestions | ✅ Available |

### Corrective Controls

| Control ID | Control Description | Implementation | Status |
|------------|---------------------|----------------|--------|
| **CC-01** | Incident response playbook | Customer-created | ⚠️ Recommended |
| **CC-02** | Automated remediation | Cloud Functions + Pub/Sub | ⚠️ Optional |
| **CC-03** | Terraform state rollback | Version control | ✅ Available |
| **CC-04** | IAM policy rollback | Audit log analysis | ✅ Available |

---

## Incident Response

### Security Incident Classification

| Severity | Definition | Example |
|----------|------------|---------|
| **P1 - Critical** | Active data breach or compromise | Unauthorized access to quality scan results containing PII |
| **P2 - High** | Potential security breach | Compromised Terraform service account credentials |
| **P3 - Medium** | Security policy violation | Overly permissive IAM binding discovered |
| **P4 - Low** | Security best practice deviation | Missing data access audit logs |

### Incident Response Plan

#### Phase 1: Identification

```yaml
Detection Sources:
  - Cloud Audit Logs alerts
  - Security Command Center findings
  - IAM recommender warnings
  - User reports

Initial Actions:
  1. Alert security team (via PagerDuty/on-call)
  2. Create incident ticket (ServiceNow/Jira)
  3. Preserve audit logs (export to Cloud Storage)
  4. Assess severity and impact
```

#### Phase 2: Containment

```bash
# Example: Compromised service account

# Step 1: Disable service account
gcloud iam service-accounts disable terraform-sa@project.iam.gserviceaccount.com

# Step 2: Revoke active tokens
gcloud iam service-accounts keys disable {KEY_ID} \
  --iam-account=terraform-sa@project.iam.gserviceaccount.com

# Step 3: Review audit logs for unauthorized activity
gcloud logging read 'protoPayload.authenticationInfo.principalEmail="terraform-sa@project.iam.gserviceaccount.com"' \
  --limit=1000 \
  --format=json > incident-audit-trail.json

# Step 4: Temporarily restrict Dataplex API access (if needed)
gcloud services disable dataplex.googleapis.com --force  # Use with caution!
```

#### Phase 3: Eradication

```yaml
Actions:
  1. Remove malicious IAM bindings:
     gcloud dataplex lakes remove-iam-policy-binding {LAKE} \
       --member="user:attacker@example.com" \
       --role="roles/dataplex.admin"

  2. Delete unauthorized resources:
     terraform destroy -target=module.dataplex.google_dataplex_lake.malicious_lake

  3. Rotate compromised credentials:
     # Create new Terraform SA, delete old one

  4. Review and update IAM policies:
     # Apply least privilege principle
```

#### Phase 4: Recovery

```yaml
Actions:
  1. Re-enable service account with new credentials
  2. Restore legitimate Dataplex resources from Terraform state
  3. Verify resource configurations match expected state
  4. Re-enable APIs if disabled during containment
  5. Monitor for 72 hours post-incident
```

#### Phase 5: Lessons Learned

```yaml
Post-Incident Review:
  1. Root cause analysis
  2. Update security controls
  3. Update incident response playbook
  4. Security awareness training (if needed)
  5. Implement additional monitoring
```

### Incident Response Contacts

```yaml
# Template - Customize for your organization

Security Team:
  - Email: security@company.com
  - On-call: +1-XXX-XXX-XXXX
  - Slack: #security-incidents

Google Cloud Support:
  - Premium Support: https://console.cloud.google.com/support
  - Phone: Per support contract
  - Severity P1: 15-minute response SLA

Compliance Team:
  - Email: compliance@company.com
  - For: GDPR breaches, HIPAA violations

Legal Team:
  - Email: legal@company.com
  - For: Data breaches requiring notification
```

---

## Security Testing

### Pre-Deployment Security Checklist

```yaml
Infrastructure-as-Code Security:
  ✅ Terraform code reviewed by security team
  ✅ No hardcoded credentials in .tf files
  ✅ Terraform state encrypted with CMEK
  ✅ State file access restricted (IAM)
  ✅ Variables validated (type constraints)

IAM Configuration:
  ✅ Least privilege roles assigned
  ✅ No overly permissive bindings (e.g., roles/owner)
  ✅ Service account usage documented
  ✅ IAM conditions applied (if needed)

Encryption:
  ✅ CMEK configured for all data at rest
  ✅ TLS 1.2+ for all API calls
  ✅ Key rotation enabled

Audit Logging:
  ✅ Admin activity logs enabled (automatic)
  ✅ Data access logs enabled (recommended)
  ✅ Log exports configured to Cloud Storage
  ✅ Log retention meets compliance requirements

Network Security:
  ✅ VPC Service Controls evaluated (if applicable)
  ✅ Private Google Access configured (if on-prem)
  ✅ No public IP addresses (N/A for Dataplex)

Compliance:
  ✅ Data residency requirements met (location parameter)
  ✅ Data classification documented
  ✅ Privacy impact assessment completed (if PII)
```

### Post-Deployment Validation

```bash
# Test 1: Verify encryption
gsutil kms encryption gs://$(terraform output -raw bucket_name)
# Expected: KMS key ARN

# Test 2: Verify audit logging
gcloud logging read 'resource.type="dataplex.googleapis.com/Lake"' --limit=10
# Expected: Recent Dataplex API calls

# Test 3: Verify IAM bindings
gcloud dataplex lakes get-iam-policy $(terraform output -raw lake_id) \
  --location=$(terraform output -raw location)
# Expected: Only authorized principals

# Test 4: Verify service account permissions
gcloud projects get-iam-policy $(terraform output -raw project_id) \
  --flatten="bindings[].members" \
  --filter="bindings.members:service-*@gcp-sa-dataplex.iam.gserviceaccount.com"
# Expected: Minimal permissions (dataViewer, objectViewer)

# Test 5: Verify no public access
gcloud dataplex lakes describe $(terraform output -raw lake_id) \
  --location=$(terraform output -raw location) \
  --format="get(iamPolicy.bindings)"
# Expected: No allUsers or allAuthenticatedUsers
```

### Penetration Testing Considerations

**Important**: Penetration testing of GCP services requires prior approval from Google.

**Allowed Testing** (with notification):
- ✅ IAM policy testing (privilege escalation attempts)
- ✅ API abuse testing (rate limiting, quota exhaustion)
- ✅ Authentication testing (token validation)

**Prohibited Testing** (without explicit approval):
- ❌ Network layer attacks (DDoS, port scanning)
- ❌ Social engineering (phishing Google employees)
- ❌ Physical security testing

**Reference**: [GCP Penetration Testing](https://support.google.com/cloud/answer/6262505)

### Security Scanning Tools

```yaml
Recommended Tools:

Static Analysis:
  - Checkov: Terraform security scanning
  - tfsec: Terraform security scanner
  - Terrascan: IaC security scanner

Example:
  checkov -d . --framework terraform
  tfsec .

Secret Scanning:
  - TruffleHog: Git secret scanner
  - git-secrets: Prevent committing secrets

Example:
  trufflehog git file://. --only-verified

Vulnerability Scanning:
  - Google Security Command Center
  - Cloud Asset Inventory

Example:
  gcloud scc findings list --organization={ORG_ID}
```

---

## Approval Checklist

### For Security Team Review

```yaml
Module Architecture Review:
  ☐ Reviewed architecture diagram
  ☐ Understand catalog-only pattern (no storage creation)
  ☐ Verified separation from ISS Foundation infrastructure
  ☐ Approved serverless/managed service approach

Data Security Review:
  ☐ Encryption at rest verified (CMEK via ISS Foundation)
  ☐ Encryption in transit verified (TLS 1.2+)
  ☐ Data access patterns reviewed (metadata-only)
  ☐ Quality scan PII implications understood

Access Control Review:
  ☐ IAM permissions documented and approved
  ☐ Service account usage validated
  ☐ Principle of least privilege confirmed
  ☐ No excessive permissions granted

Audit & Compliance Review:
  ☐ Cloud Audit Logs verified (admin + data access)
  ☐ Log retention meets compliance requirements
  ☐ Compliance frameworks alignment reviewed
  ☐ Data residency requirements addressed

Threat Model Review:
  ☐ Threats identified and analyzed
  ☐ Mitigations validated
  ☐ Residual risk acceptable
  ☐ Incident response plan in place

Network Security Review:
  ☐ VPC Service Controls evaluated
  ☐ Private Google Access configured (if needed)
  ☐ No public endpoints confirmed

Operational Security Review:
  ☐ Deployment process uses IaC
  ☐ Terraform state secured
  ☐ Change management process defined
  ☐ Security testing plan approved

Documentation Review:
  ☐ Security documentation complete
  ☐ Operational runbooks available
  ☐ Incident response procedures defined
  ☐ Compliance artifacts provided

Final Approval:
  ☐ Security team approval
  ☐ Compliance team approval (if applicable)
  ☐ Architecture team approval
  ☐ Risk accepted by business owner
```

### Approval Sign-off

```yaml
Approvers:

Security Team:
  Name: _______________________
  Title: CISO / Security Architect
  Date: _______________________
  Signature: __________________

Compliance Team (if applicable):
  Name: _______________________
  Title: Compliance Officer
  Date: _______________________
  Signature: __________________

Business Owner:
  Name: _______________________
  Title: Data Platform Lead
  Date: _______________________
  Signature: __________________

Risk Acceptance:
  Residual Risk Level: LOW
  Accepted By: _______________________
  Date: _______________________
```

---

## Appendices

### Appendix A: Security References

- [GCP Dataplex Security Documentation](https://cloud.google.com/dataplex/docs/security-best-practices)
- [GCP Security Best Practices](https://cloud.google.com/security/best-practices)
- [GCP Compliance Offerings](https://cloud.google.com/security/compliance/offerings)
- [GCP Audit Logs](https://cloud.google.com/logging/docs/audit)
- [GCP VPC Service Controls](https://cloud.google.com/vpc-service-controls/docs)
- [CIS Google Cloud Platform Foundation Benchmark](https://www.cisecurity.org/benchmark/google_cloud_computing_platform)

### Appendix B: Glossary

| Term | Definition |
|------|------------|
| **CMEK** | Customer-Managed Encryption Keys - Encryption keys managed by customer in Cloud KMS |
| **Dataplex Asset** | Reference to a GCS bucket or BigQuery dataset within a Dataplex zone |
| **Dataplex Lake** | Top-level organizational unit in Dataplex |
| **Dataplex Zone** | Subdivision of a lake (RAW or CURATED) |
| **ISS Foundation** | GCP Infrastructure Self-Service Foundation framework |
| **Metadata** | Data about data (schema, statistics, locations), not the data itself |
| **Quality Scan** | Automated data quality validation (NON_NULL, UNIQUENESS, etc.) |
| **Service Account** | Non-human identity used by applications and services |
| **VPC-SC** | VPC Service Controls - Network perimeter security |

### Appendix C: Contact Information

```yaml
Module Maintainer:
  GitHub: https://github.com/Abhishek-Kraj/Dataplex-Universal-Catalog
  Issues: https://github.com/Abhishek-Kraj/Dataplex-Universal-Catalog/issues

Google Cloud Support:
  Documentation: https://cloud.google.com/dataplex/docs
  Support: https://console.cloud.google.com/support

Security Reporting:
  Google Cloud Security: https://cloud.google.com/security/disclosure
  Module Security Issues: security@company.com (customize)
```

---

**Document End**

---

**Approval Status**: ☐ Pending Review
**Next Review Date**: _______________
**Document Owner**: Security Team
**Distribution**: Internal - Security, Compliance, Architecture Teams

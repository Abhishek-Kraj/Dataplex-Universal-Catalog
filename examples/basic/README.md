# Basic Example - Terraform-Supported Features

This example demonstrates a **production-ready deployment** using ONLY features that are **fully supported in Terraform**.

## ✅ What's Included (All Terraform-Supported)

This example deploys:

### **Infrastructure**
- 1 Data Lake (`analytics-lake`)
- 2 Zones (`bronze-zone`, `silver-zone`)
- Automatic asset registration (GCS bucket + BigQuery dataset)

### **Catalog & Metadata**
- 2 Entry Groups (`customer-data-group`, `product-data-group`)
- Entry Types and Aspect Types (schemas)
- Data classification taxonomy with 4 policy tags

### **Security**
- IAM bindings for lake access
- Service accounts
- Policy tags for column-level security
- KMS encryption

### **Data Quality**
- 1 Quality scan with 3 validation rules
- 1 Profiling scan for statistical analysis
- BigQuery datasets for results storage

### **Processing**
- 1 Spark job for Bronze→Silver ETL
- Task scheduling
- Artifact storage

### **Monitoring**
- Alert policies for quality failures
- Monitoring dashboards
- Log-based metrics

## 🚫 What's NOT Included (Not Terraform-Supported)

- ❌ Search interface (use Console)
- ❌ Business glossaries (use `gcloud` CLI)
- ❌ Column-level aspects (use SDK/API)
- ❌ Data lineage (auto-generated)

## 📋 Configuration

**Project**: `prusandbx-nprd-uat-iywjo9`
**Region**: `asia-southeast1` (Singapore)

## 🚀 Deploy

```bash
# 1. Navigate to this directory
cd examples/basic

# 2. Initialize Terraform
terraform init

# 3. Review the plan
terraform plan

# 4. Deploy
terraform apply

# 5. View outputs
terraform output
```

## 📊 Expected Resources

After deployment, you'll have:

| Resource Type | Count | Examples |
|--------------|-------|----------|
| **Lakes** | 1 | analytics-lake |
| **Zones** | 2 | bronze-zone, silver-zone |
| **Entry Groups** | 2 | customer-data, product-data |
| **Policy Tags** | 4 | Confidential, Internal, Public, PII |
| **Quality Scans** | 1 | customer-quality-scan |
| **Profiling Scans** | 1 | customer-profile-scan |
| **Spark Jobs** | 1 | bronze-to-silver-etl |
| **BigQuery Datasets** | 5+ | Various for scans and storage |
| **GCS Buckets** | 2+ | Raw zone storage, artifacts |
| **Service Accounts** | 2 | Dataplex ops, Spark runner |
| **Alert Policies** | 3 | Quality, scan, lake health |

**Total**: ~30-35 resources

## 🔍 Verify Deployment

```bash
# Check lakes
gcloud dataplex lakes list \
  --location=asia-southeast1 \
  --project=prusandbx-nprd-uat-iywjo9

# Check taxonomies
gcloud data-catalog taxonomies list \
  --location=asia-southeast1 \
  --project=prusandbx-nprd-uat-iywjo9

# Check data scans
gcloud dataplex datascans list \
  --location=asia-southeast1 \
  --project=prusandbx-nprd-uat-iywjo9

# Check entry groups
gcloud dataplex entry-groups list \
  --location=asia-southeast1 \
  --project=prusandbx-nprd-uat-iywjo9
```

## 🧹 Cleanup

```bash
terraform destroy
```

## 📝 Notes

- This example uses **100% Terraform-supported features**
- No manual steps required after deployment
- All infrastructure is reproducible
- Configuration is version-controlled

For features not supported in Terraform, see `../../TERRAFORM_SUPPORT.md`.

## 💡 Next Steps

1. Review created resources in GCP Console
2. Test data quality scan functionality
3. View monitoring dashboards
4. Explore entry groups and aspect types
5. Customize for your data sources

## 🎯 Production Readiness

This example is production-ready:
- ✅ Security best practices (IAM, KMS, audit logging)
- ✅ Monitoring and alerting configured
- ✅ Data quality automation
- ✅ Scalable architecture
- ✅ Infrastructure as code (100% Terraform)

---

**Coverage**: This example represents the **65% of Dataplex features** that are fully supported in Terraform.

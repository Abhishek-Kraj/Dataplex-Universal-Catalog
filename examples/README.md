# Dataplex Universal Catalog - Examples

This directory contains example implementations of the Dataplex Universal Catalog module.

## 📁 Available Examples

### 1. Basic Example (`basic/`)
**Purpose**: Minimal setup for getting started quickly

**Includes**:
- 1 Lake with 2 zones (RAW, CURATED)
- Data Catalog taxonomy with 3 policy tags
- 1 Entry group
- Metadata templates
- Basic search infrastructure

**Use Case**: Development, testing, proof-of-concept

**Deployment Time**: ~5-10 minutes

**Navigate**:
```bash
cd basic/
```

### 2. Complete Example (`complete/`)
**Purpose**: Full-featured enterprise deployment

**Includes**:
- 3 Lakes with 5 zones
- 8 policy tags for data classification
- 4 Entry groups
- 2 Business glossaries with terms
- 3 Data quality scans with 15+ rules
- 3 Data profiling scans
- IAM bindings
- Spark jobs
- Security features (KMS, audit logging)
- Monitoring dashboards and alerts

**Use Case**: Production, enterprise deployments

**Deployment Time**: ~15-20 minutes

**Navigate**:
```bash
cd complete/
```

---

## 🚀 How to Use

### Step 1: Choose an Example

Start with **basic** for your first deployment:
```bash
cd basic/
```

### Step 2: Configure Variables

The configuration is already set for:
- **Project**: `prusandbx-nprd-uat-iywjo9`
- **Region**: `asia-southeast1` (Singapore)

To customize further:
```bash
# View example configuration
cat terraform.tfvars.example

# Edit your configuration
nano terraform.tfvars
```

### Step 3: Initialize Terraform

```bash
terraform init
```

Expected output:
```
Initializing modules...
Initializing the backend...
Initializing provider plugins...
Terraform has been successfully initialized!
```

### Step 4: Plan the Deployment

```bash
terraform plan
```

Review the resources that will be created. Expected resources for basic example: **20-30 resources**.

### Step 5: Deploy

```bash
terraform apply
```

Type `yes` when prompted.

### Step 6: Verify Deployment

```bash
# View Terraform outputs
terraform output

# Check lakes
gcloud dataplex lakes list \
  --location=asia-southeast1 \
  --project=prusandbx-nprd-uat-iywjo9

# Check taxonomies
gcloud data-catalog taxonomies list \
  --location=asia-southeast1 \
  --project=prusandbx-nprd-uat-iywjo9
```

### Step 7: Cleanup (Optional)

When you're done testing:
```bash
terraform destroy
```

Type `yes` when prompted.

---

## 📊 Comparison Matrix

| Feature | Basic | Complete |
|---------|-------|----------|
| **Lakes** | 1 | 3 |
| **Zones** | 2 | 5 |
| **Policy Tags** | 3 | 8 |
| **Entry Groups** | 1 | 4 |
| **Glossaries** | 0 | 2 with terms |
| **Quality Scans** | 0 | 3 with 15+ rules |
| **Profiling Scans** | 0 | 3 |
| **IAM Bindings** | No | Yes |
| **Security Features** | No | Yes (KMS, logging) |
| **Spark Jobs** | No | Yes |
| **Monitoring** | No | Yes (dashboards, alerts) |
| **Resources Created** | ~25 | ~80+ |
| **Deployment Time** | 5-10 min | 15-20 min |
| **Monthly Cost (Est)** | $20-50 | $100-200 |

---

## 🎯 Learning Path

### Phase 1: Basic Understanding
1. Deploy **basic** example
2. Explore created resources in GCP Console
3. Understand module structure
4. Review Terraform state

### Phase 2: Customization
1. Modify basic example variables
2. Add custom policy tags
3. Change region/location
4. Add labels

### Phase 3: Advanced Features
1. Deploy **complete** example
2. Configure quality scans
3. Set up IAM bindings
4. Enable monitoring

### Phase 4: Production
1. Create custom configuration
2. Add organization-specific glossaries
3. Configure data quality rules
4. Set up alerting policies

---

## 📝 Common Customizations

### Change Region

Edit `terraform.tfvars`:
```hcl
region   = "us-central1"  # Change to your preferred region
location = "us-central1"
```

### Add Policy Tags

Edit `main.tf`:
```hcl
discover_config = {
  policy_tags = [
    "Confidential",
    "Public",
    "Internal",
    "My-Custom-Tag"  # Add your tag
  ]
}
```

### Add More Lakes

Edit `main.tf`:
```hcl
manage_lakes_config = {
  lakes = [
    {
      lake_id = "analytics-lake"
      zones = [...]
    },
    {
      lake_id = "my-new-lake"  # Add new lake
      display_name = "My New Lake"
      zones = [
        {
          zone_id = "my-zone"
          type    = "RAW"
        }
      ]
    }
  ]
}
```

### Configure Quality Checks

Edit `main.tf` (complete example):
```hcl
govern_config = {
  quality_scans = [
    {
      scan_id = "my-quality-scan"
      lake_id = "analytics-lake"
      data_source = "//bigquery.googleapis.com/projects/MY_PROJECT/datasets/MY_DATASET/tables/MY_TABLE"
      rules = [
        {
          rule_type = "NON_NULL"
          column    = "id"
          threshold = 1.0
        }
      ]
    }
  ]
}
```

---

## 🔍 Troubleshooting

### Error: API Not Enabled

**Solution**:
```bash
gcloud services enable dataplex.googleapis.com \
  --project=prusandbx-nprd-uat-iywjo9
```

### Error: Permission Denied

**Solution**: Ensure your service account has required roles:
- `roles/dataplex.admin`
- `roles/datacatalog.admin`
- `roles/bigquery.admin`
- `roles/storage.admin`

### Error: Resource Already Exists

**Solution**: Import existing resource or use different IDs:
```bash
terraform import google_dataplex_lake.example projects/PROJECT/locations/LOCATION/lakes/LAKE_ID
```

### Error: Invalid Variable Value

**Solution**: Check variable validations in error message. Common issues:
- Search scope must be "PROJECT" or "ORGANIZATION"
- Search result limit must be 1-1000
- Zone type must be "RAW" or "CURATED"

---

## 📚 Next Steps

After successfully deploying an example:

1. **Explore GCP Console**
   - Navigate to Dataplex in GCP Console
   - View created lakes, zones, and assets
   - Check Data Catalog for taxonomies

2. **Review Documentation**
   - `../VARIABLES_GUIDE.md` - Complete variable reference
   - `../README.md` - Module overview
   - `../DEPLOYMENT_GUIDE.md` - Deployment best practices

3. **Customize for Your Needs**
   - Copy example to new directory
   - Modify variables
   - Add organization-specific configuration

4. **Plan Production Deployment**
   - Review security requirements
   - Plan data classification strategy
   - Define quality rules
   - Set up monitoring and alerting

---

## 💡 Tips

- **Start Small**: Begin with basic example, gradually add features
- **Use Version Control**: Track your `terraform.tfvars` changes
- **Test First**: Deploy to dev environment before production
- **Review Plans**: Always review `terraform plan` output before applying
- **Document Changes**: Keep notes on customizations
- **Monitor Costs**: Review GCP billing for cost optimization

---

## 📞 Support

For issues or questions:
1. Check `../TROUBLESHOOTING.md`
2. Review Terraform error messages carefully
3. Consult GCP Dataplex documentation
4. Open an issue in the repository

---

**Happy Deploying! 🚀**

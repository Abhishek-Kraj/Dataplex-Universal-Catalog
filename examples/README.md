# Dataplex Universal Catalog - Examples

This directory contains example implementations of the Dataplex Universal Catalog module.

## 📁 Available Examples

### Example (`example/`)
**Purpose**: Comprehensive example demonstrating all module capabilities

**Includes**:
- 1 Lake with 10 zones (RAW and CURATED)
- All zone/storage combinations (RAW+GCS, RAW+BigQuery, CURATED+GCS, CURATED+BigQuery)
- Data Catalog taxonomy with 3 policy tags
- 1 Entry group with custom metadata templates
- Business glossary with terms
- Data quality scans with multiple rules
- Data profiling scans
- Discovery settings
- Search infrastructure

**Use Case**: Development, testing, proof-of-concept, production reference

**Deployment Time**: ~10-15 minutes

**Navigate**:
```bash
cd example/
```

---

## 🚀 How to Use

### Step 1: Navigate to Example

```bash
cd example/
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

Review the resources that will be created. Expected resources: **~47 resources**.

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

## 📊 Example Features

| Feature | Included |
|---------|----------|
| **Lakes** | 1 |
| **Zones** | 10 (all combinations) |
| **Zone Types** | RAW + CURATED |
| **Storage Types** | GCS Buckets + BigQuery Datasets |
| **Policy Tags** | 3 |
| **Entry Groups** | 1 with metadata templates |
| **Glossaries** | 1 with terms |
| **Quality Scans** | Yes (multiple rules) |
| **Profiling Scans** | Yes |
| **Discovery Settings** | Yes |
| **Resources Created** | ~47 |
| **Deployment Time** | 10-15 min |

---

## 🎯 Learning Path

### Phase 1: Basic Understanding
1. Deploy the example
2. Explore created resources in GCP Console
3. Understand module structure
4. Review Terraform state

### Phase 2: Customization
1. Modify example variables
2. Add custom policy tags
3. Change region/location
4. Test different zone/storage combinations

### Phase 3: Production Planning
1. Create custom configuration for your organization
2. Add organization-specific glossaries
3. Configure data quality rules
4. Plan data classification strategy

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

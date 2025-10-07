#!/bin/bash

# Quick Test Deployment Script
# Project: prusandbx-nprd-uat-iywjo9

set -e

PROJECT_ID="prusandbx-nprd-uat-iywjo9"
EXAMPLE_DIR="examples/basic"

echo "=========================================="
echo "Testing Dataplex Module Deployment"
echo "Project: ${PROJECT_ID}"
echo "=========================================="

# Step 1: Check if gcloud is configured
echo ""
echo "[Step 1] Checking GCP authentication..."
if gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    echo "✓ Authenticated with: $(gcloud auth list --filter=status:ACTIVE --format='value(account)')"
else
    echo "✗ Not authenticated. Please run: gcloud auth login"
    exit 1
fi

# Step 2: Set project
echo ""
echo "[Step 2] Setting project..."
gcloud config set project ${PROJECT_ID}
echo "✓ Project set to: ${PROJECT_ID}"

# Step 3: Check required APIs
echo ""
echo "[Step 3] Checking required APIs..."
REQUIRED_APIS=(
    "dataplex.googleapis.com"
    "datacatalog.googleapis.com"
    "bigquery.googleapis.com"
    "storage.googleapis.com"
)

for API in "${REQUIRED_APIS[@]}"; do
    if gcloud services list --enabled --filter="name:${API}" --format="value(name)" | grep -q "${API}"; then
        echo "✓ ${API} is enabled"
    else
        echo "⚠ ${API} is NOT enabled. Enabling..."
        gcloud services enable ${API} --project=${PROJECT_ID}
    fi
done

# Step 4: Navigate to example directory
echo ""
echo "[Step 4] Navigating to ${EXAMPLE_DIR}..."
cd ${EXAMPLE_DIR}

# Step 5: Initialize Terraform
echo ""
echo "[Step 5] Initializing Terraform..."
terraform init

# Step 6: Format check
echo ""
echo "[Step 6] Formatting Terraform files..."
terraform fmt -recursive

# Step 7: Validate
echo ""
echo "[Step 7] Validating Terraform configuration..."
terraform validate

# Step 8: Plan
echo ""
echo "[Step 8] Creating Terraform plan..."
terraform plan -out=tfplan

echo ""
echo "=========================================="
echo "✓ Pre-deployment checks complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Review the plan above"
echo "2. To deploy, run:"
echo "   cd ${EXAMPLE_DIR}"
echo "   terraform apply tfplan"
echo ""
echo "3. To destroy later, run:"
echo "   cd ${EXAMPLE_DIR}"
echo "   terraform destroy"
echo "=========================================="

#!/bin/bash

# POC Deployment Script for Dataplex Universal Catalog
# Project: prusandbx-nprd-uat-iywjo9

set -e

PROJECT_ID="prusandbx-nprd-uat-iywjo9"
REGION="us-central1"
LOCATION="us-central1"

echo "=================================================="
echo "Dataplex Universal Catalog - POC Deployment"
echo "Project: ${PROJECT_ID}"
echo "=================================================="

# Step 1: Enable Required APIs
echo ""
echo "[1/5] Enabling required APIs..."
gcloud services enable \
  dataplex.googleapis.com \
  datacatalog.googleapis.com \
  bigquery.googleapis.com \
  storage-api.googleapis.com \
  cloudkms.googleapis.com \
  monitoring.googleapis.com \
  logging.googleapis.com \
  --project=${PROJECT_ID} \
  --quiet

echo "✓ APIs enabled successfully"

# Step 2: Initialize Terraform
echo ""
echo "[2/5] Initializing Terraform..."
cd examples/basic
terraform init

echo "✓ Terraform initialized"

# Step 3: Validate Configuration
echo ""
echo "[3/5] Validating Terraform configuration..."
terraform validate

echo "✓ Configuration valid"

# Step 4: Create Terraform Plan
echo ""
echo "[4/5] Creating deployment plan..."
terraform plan -out=tfplan

echo "✓ Plan created"

# Step 5: Show Plan Summary
echo ""
echo "[5/5] Deployment Summary:"
echo "=================================================="
terraform show -no-color tfplan | grep -E "^(  # |Plan:)" || true

echo ""
echo "=================================================="
echo "Ready to deploy!"
echo ""
echo "To apply the changes, run:"
echo "  cd examples/basic"
echo "  terraform apply tfplan"
echo ""
echo "To destroy resources later, run:"
echo "  cd examples/basic"
echo "  terraform destroy"
echo "=================================================="

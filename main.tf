/**
 * Copyright 2025 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# ==============================================================================
# DATAPLEX UNIVERSAL CATALOG MODULE
# ==============================================================================
# This module provides a unified interface for managing Google Cloud Dataplex
# resources including lakes, zones, assets, metadata catalog, and governance.
# ==============================================================================

# Manage Lakes Module
module "manage_lakes" {
  source = "./modules/manage-lakes"
  count  = var.enable_manage_lakes ? 1 : 0

  project_id = var.project_id
  region     = var.region
  location   = var.location

  enable_manage  = var.enable_manage
  enable_secure  = var.enable_secure
  enable_process = var.enable_process

  lakes        = var.lakes
  iam_bindings = var.iam_bindings
  spark_jobs   = var.spark_jobs

  labels = var.labels
}

# Metadata Management Module
module "manage_metadata" {
  source = "./modules/manage-metadata"
  count  = var.enable_metadata ? 1 : 0

  project_id = var.project_id
  region     = var.region
  location   = var.location

  enable_catalog     = var.enable_catalog
  enable_glossaries  = var.enable_glossaries

  entry_groups = var.entry_groups
  glossaries   = var.glossaries

  labels = var.labels
}

# Governance Module
module "govern" {
  source = "./modules/govern"
  count  = var.enable_governance ? 1 : 0

  project_id = var.project_id
  region     = var.region
  location   = var.location

  enable_profiling  = var.enable_profiling
  enable_quality    = var.enable_quality
  enable_monitoring = var.enable_monitoring

  quality_scans   = var.quality_scans
  profiling_scans = var.profiling_scans

  labels = var.labels
}

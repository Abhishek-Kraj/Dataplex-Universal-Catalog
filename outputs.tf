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
# MANAGE LAKES OUTPUTS
# ==============================================================================

output "lakes" {
  description = "Map of created Dataplex lakes"
  value       = var.enable_manage_lakes ? module.manage_lakes[0].lakes : {}
}

output "zones" {
  description = "Map of created Dataplex zones"
  value       = var.enable_manage_lakes ? module.manage_lakes[0].zones : {}
}

output "assets" {
  description = "Map of created Dataplex assets"
  value       = var.enable_manage_lakes ? module.manage_lakes[0].assets : {}
}

output "tasks" {
  description = "Map of created Dataplex tasks"
  value       = var.enable_manage_lakes ? module.manage_lakes[0].tasks : {}
}

# ==============================================================================
# METADATA MANAGEMENT OUTPUTS
# ==============================================================================

output "entry_groups" {
  description = "Map of created entry groups"
  value       = var.enable_metadata ? module.manage_metadata[0].entry_groups : {}
}

output "entry_types" {
  description = "Map of created entry types"
  value       = var.enable_metadata ? module.manage_metadata[0].entry_types : {}
}

output "aspect_types" {
  description = "Map of created aspect types"
  value       = var.enable_metadata ? module.manage_metadata[0].aspect_types : {}
}

output "glossary_datasets" {
  description = "BigQuery datasets for glossaries"
  value       = var.enable_metadata ? module.manage_metadata[0].glossary_dataset : null
}

output "glossary_tables" {
  description = "BigQuery tables for glossary data"
  value       = var.enable_metadata ? module.manage_metadata[0].glossary_tables : {}
}

# ==============================================================================
# GOVERNANCE OUTPUTS
# ==============================================================================

output "quality_scans" {
  description = "Map of created data quality scans"
  value       = var.enable_governance ? module.govern[0].quality_scans : {}
}

output "profiling_scans" {
  description = "Map of created data profiling scans"
  value       = var.enable_governance ? module.govern[0].profiling_scans : {}
}

output "quality_dataset" {
  description = "BigQuery dataset for quality results"
  value       = var.enable_governance ? module.govern[0].quality_dataset : null
}

output "profiling_dataset" {
  description = "BigQuery dataset for profiling results"
  value       = var.enable_governance ? module.govern[0].profiling_dataset : null
}

output "monitoring_dashboards" {
  description = "Monitoring dashboard URLs"
  value       = var.enable_governance && var.enable_monitoring ? module.govern[0].dashboard_url : null
}

output "alert_policies" {
  description = "Alert policy IDs"
  value       = var.enable_governance && var.enable_monitoring ? module.govern[0].alert_policy_ids : []
}

# ==============================================================================
# GENERAL OUTPUTS
# ==============================================================================

output "project_id" {
  description = "The GCP project ID"
  value       = var.project_id
}

output "region" {
  description = "The GCP region"
  value       = var.region
}

output "location" {
  description = "The GCP location"
  value       = var.location
}

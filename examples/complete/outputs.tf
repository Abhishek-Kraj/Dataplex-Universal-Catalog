# Unified Module Outputs
output "lakes" {
  description = "All created Dataplex lakes"
  value       = module.dataplex.lakes
}

output "zones" {
  description = "All created Dataplex zones"
  value       = module.dataplex.zones
}

output "assets" {
  description = "All created Dataplex assets"
  value       = module.dataplex.assets
}

output "tasks" {
  description = "All created Dataplex tasks"
  value       = module.dataplex.tasks
}

output "entry_groups" {
  description = "All created entry groups"
  value       = module.dataplex.entry_groups
}

output "entry_types" {
  description = "All created entry types"
  value       = module.dataplex.entry_types
}

output "aspect_types" {
  description = "All created aspect types"
  value       = module.dataplex.aspect_types
}

output "glossary_datasets" {
  description = "BigQuery datasets for glossaries"
  value       = module.dataplex.glossary_datasets
}

output "quality_scans" {
  description = "All created data quality scans"
  value       = module.dataplex.quality_scans
}

output "profiling_scans" {
  description = "All created data profiling scans"
  value       = module.dataplex.profiling_scans
}

output "quality_dataset" {
  description = "BigQuery dataset for quality results"
  value       = module.dataplex.quality_dataset
}

output "profiling_dataset" {
  description = "BigQuery dataset for profiling results"
  value       = module.dataplex.profiling_dataset
}

output "monitoring_dashboards" {
  description = "Monitoring dashboard URLs"
  value       = module.dataplex.monitoring_dashboards
}

output "alert_policies" {
  description = "Alert policy IDs"
  value       = module.dataplex.alert_policies
}

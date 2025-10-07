# Manage Lakes Outputs
output "lakes" {
  description = "All created Dataplex lakes"
  value       = module.manage_lakes.lakes
}

output "zones" {
  description = "All created Dataplex zones"
  value       = module.manage_lakes.zones
}

output "assets" {
  description = "All created Dataplex assets"
  value       = module.manage_lakes.assets
}

output "tasks" {
  description = "All created Dataplex tasks"
  value       = module.manage_lakes.tasks
}

# Manage Metadata Outputs
output "entry_groups" {
  description = "All created entry groups"
  value       = module.manage_metadata.entry_groups
}

output "glossaries" {
  description = "All created business glossaries"
  value       = module.manage_metadata.glossaries
}

# Govern Outputs
output "quality_scans" {
  description = "All created data quality scans"
  value       = module.govern.quality_scans
}

output "profiling_scans" {
  description = "All created data profiling scans"
  value       = module.govern.profiling_scans
}

output "monitoring_dashboards" {
  description = "Monitoring dashboard URLs"
  value       = module.govern.monitoring_dashboards
}

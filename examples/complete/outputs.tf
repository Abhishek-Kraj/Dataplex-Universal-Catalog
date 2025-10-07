output "taxonomy_id" {
  description = "The ID of the created taxonomy"
  value       = module.dataplex.discover_taxonomy_id
}

output "policy_tags" {
  description = "Created policy tags"
  value       = module.dataplex.discover_policy_tags
}

output "lakes" {
  description = "Created lakes"
  value       = module.dataplex.lakes
}

output "zones" {
  description = "Created zones"
  value       = module.dataplex.zones
}

output "assets" {
  description = "Created assets"
  value       = module.dataplex.assets
}

output "entry_groups" {
  description = "Created entry groups"
  value       = module.dataplex.entry_groups
}

output "glossaries" {
  description = "Created glossaries"
  value       = module.dataplex.glossaries
}

output "quality_scans" {
  description = "Created quality scans"
  value       = module.dataplex.quality_scans
}

output "profiling_scans" {
  description = "Created profiling scans"
  value       = module.dataplex.profiling_scans
}

output "monitoring_dashboards" {
  description = "Created monitoring dashboards"
  value       = module.dataplex.monitoring_dashboards
}

output "module_status" {
  description = "Status of enabled modules"
  value       = module.dataplex.module_status
}

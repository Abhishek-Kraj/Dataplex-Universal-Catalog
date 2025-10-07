# Manage Lakes Outputs
output "lakes" {
  description = "Created Dataplex lakes"
  value       = module.manage_lakes.lakes
}

output "zones" {
  description = "Created Dataplex zones"
  value       = module.manage_lakes.zones
}

output "assets" {
  description = "Created Dataplex assets"
  value       = module.manage_lakes.assets
}

# Manage Metadata Outputs
output "entry_groups" {
  description = "Created entry groups"
  value       = module.manage_metadata.entry_groups
}

# Govern Outputs
output "quality_scans" {
  description = "Created quality scans"
  value       = module.govern.quality_scans
}

output "profiling_scans" {
  description = "Created profiling scans"
  value       = module.govern.profiling_scans
}

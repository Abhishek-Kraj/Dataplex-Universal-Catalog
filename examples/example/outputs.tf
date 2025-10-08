# Unified Module Outputs
output "lakes" {
  description = "Created Dataplex lakes"
  value       = module.dataplex.lakes
}

output "zones" {
  description = "Created Dataplex zones"
  value       = module.dataplex.zones
}

output "assets" {
  description = "Created Dataplex assets"
  value       = module.dataplex.assets
}

output "entry_groups" {
  description = "Created entry groups"
  value       = module.dataplex.entry_groups
}

output "entry_types" {
  description = "Created entry types"
  value       = module.dataplex.entry_types
}

output "aspect_types" {
  description = "Created aspect types"
  value       = module.dataplex.aspect_types
}

output "quality_scans" {
  description = "Created quality scans"
  value       = module.dataplex.quality_scans
}

output "profiling_scans" {
  description = "Created profiling scans"
  value       = module.dataplex.profiling_scans
}

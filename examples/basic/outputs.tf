output "taxonomy_id" {
  description = "The ID of the created taxonomy"
  value       = module.dataplex.discover_taxonomy_id
}

output "lakes" {
  description = "Created lakes"
  value       = module.dataplex.lakes
}

output "entry_groups" {
  description = "Created entry groups"
  value       = module.dataplex.entry_groups
}

output "module_status" {
  description = "Status of enabled modules"
  value       = module.dataplex.module_status
}

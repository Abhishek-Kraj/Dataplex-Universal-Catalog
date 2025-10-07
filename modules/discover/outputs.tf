output "taxonomy_id" {
  description = "The ID of the created taxonomy"
  value       = try(module.taxonomy[0].taxonomy_id, null)
}

output "policy_tags" {
  description = "Map of policy tag names to their IDs"
  value       = try(module.taxonomy[0].policy_tags, {})
}

output "search_config" {
  description = "Search configuration details"
  value       = try(module.search[0].search_config, {})
}

output "metadata_templates" {
  description = "Map of metadata template IDs"
  value       = try(module.templates[0].templates, {})
}

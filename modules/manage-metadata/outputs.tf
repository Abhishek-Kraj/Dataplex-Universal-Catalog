output "entry_groups" {
  description = "Map of entry group IDs to their details"
  value       = try(module.catalog[0].entry_groups, {})
}

output "glossaries" {
  description = "Map of glossary IDs to their details"
  value       = try(module.glossaries[0].glossaries, {})
}

output "glossary_terms" {
  description = "Map of glossary terms"
  value       = try(module.glossaries[0].glossary_terms, {})
}

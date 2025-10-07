# Root Module Outputs

# Discover Module Outputs
output "discover_taxonomy_id" {
  description = "The ID of the created taxonomy"
  value       = try(module.discover[0].taxonomy_id, null)
}

output "discover_policy_tags" {
  description = "Map of policy tag names to their IDs"
  value       = try(module.discover[0].policy_tags, {})
}

output "discover_search_config" {
  description = "Search configuration details"
  value       = try(module.discover[0].search_config, {})
}

# Manage Metadata Module Outputs
output "entry_groups" {
  description = "Map of entry group IDs to their details"
  value       = try(module.manage_metadata[0].entry_groups, {})
}

output "glossaries" {
  description = "Map of glossary IDs to their details"
  value       = try(module.manage_metadata[0].glossaries, {})
}

output "glossary_terms" {
  description = "Map of glossary terms"
  value       = try(module.manage_metadata[0].glossary_terms, {})
}

# Manage Lakes Module Outputs
output "lakes" {
  description = "Map of lake IDs to their details"
  value       = try(module.manage_lakes[0].lakes, {})
}

output "zones" {
  description = "Map of zone IDs to their details"
  value       = try(module.manage_lakes[0].zones, {})
}

output "assets" {
  description = "Map of asset IDs to their details"
  value       = try(module.manage_lakes[0].assets, {})
}

output "spark_jobs" {
  description = "Map of Spark job IDs to their details"
  value       = try(module.manage_lakes[0].spark_jobs, {})
}

# Govern Module Outputs
output "quality_scans" {
  description = "Map of quality scan IDs to their details"
  value       = try(module.govern[0].quality_scans, {})
}

output "profiling_scans" {
  description = "Map of profiling scan IDs to their details"
  value       = try(module.govern[0].profiling_scans, {})
}

output "monitoring_dashboards" {
  description = "Map of monitoring dashboard IDs"
  value       = try(module.govern[0].monitoring_dashboards, {})
}

# Summary Output
output "module_status" {
  description = "Status of enabled modules"
  value = {
    discover         = var.enable_discover
    manage_metadata  = var.enable_manage_metadata
    manage_lakes     = var.enable_manage_lakes
    govern           = var.enable_govern
  }
}

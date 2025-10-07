output "quality_scans" {
  description = "Map of quality scan IDs to their details"
  value       = try(module.quality[0].quality_scans, {})
}

output "profiling_scans" {
  description = "Map of profiling scan IDs to their details"
  value       = try(module.profiling[0].profiling_scans, {})
}

output "monitoring_dashboards" {
  description = "Map of monitoring dashboard IDs"
  value       = try(module.monitoring[0].dashboards, {})
}

output "alert_policies" {
  description = "Map of alert policy IDs"
  value       = try(module.monitoring[0].alert_policies, {})
}

output "quality_scans" {
  description = "Map of quality scan IDs to their details"
  value       = google_dataplex_datascan.quality_scans
}

output "profiling_scans" {
  description = "Map of profiling scan IDs to their details"
  value       = google_dataplex_datascan.profiling_scans
}

output "quality_dataset" {
  description = "BigQuery dataset for quality scan results"
  value       = try(google_bigquery_dataset.quality_results[0], null)
}

output "profiling_dataset" {
  description = "BigQuery dataset for profiling scan results"
  value       = try(google_bigquery_dataset.profiling_results[0], null)
}

output "dashboard_url" {
  description = "Monitoring dashboard URL"
  value       = try(google_monitoring_dashboard.dataplex_overview[0].id, null)
}

output "alert_policy_ids" {
  description = "List of alert policy IDs"
  value = compact([
    try(google_monitoring_alert_policy.quality_failures[0].id, ""),
    try(google_monitoring_alert_policy.scan_failures[0].id, ""),
    try(google_monitoring_alert_policy.lake_health[0].id, "")
  ])
}

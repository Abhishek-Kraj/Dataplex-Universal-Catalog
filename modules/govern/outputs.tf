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
  value       = var.enable_quality ? google_bigquery_dataset.quality_results : null
}

output "profiling_dataset" {
  description = "BigQuery dataset for profiling scan results"
  value       = var.enable_profiling ? google_bigquery_dataset.profiling_results : null
}

output "dashboard_url" {
  description = "Monitoring dashboard URL"
  value       = var.enable_monitoring ? google_monitoring_dashboard.dataplex_overview.id : null
}

output "alert_policy_ids" {
  description = "List of alert policy IDs"
  value       = var.enable_monitoring ? [
    google_monitoring_alert_policy.quality_failures.id,
    google_monitoring_alert_policy.scan_failures.id,
    google_monitoring_alert_policy.lake_health.id
  ] : []
}

output "quality_scans" {
  description = "Map of quality scan IDs to their details"
  value = {
    for k, v in google_dataplex_datascan.quality_scans : k => {
      id           = v.id
      name         = v.name
      uid          = v.uid
      display_name = v.display_name
      state        = v.state
      type         = v.type
    }
  }
}

output "quality_results_dataset_id" {
  description = "BigQuery dataset ID for quality results"
  value       = google_bigquery_dataset.quality_results.dataset_id
}

output "quality_scan_results_table_id" {
  description = "BigQuery table ID for quality scan results"
  value       = google_bigquery_table.quality_scan_results.table_id
}

output "quality_rule_results_table_id" {
  description = "BigQuery table ID for quality rule results"
  value       = google_bigquery_table.quality_rule_results.table_id
}

output "quality_trends_view_id" {
  description = "BigQuery view ID for quality trends"
  value       = google_bigquery_table.quality_trends_view.table_id
}

output "failed_rules_view_id" {
  description = "BigQuery view ID for failed quality rules"
  value       = google_bigquery_table.failed_rules_view.table_id
}

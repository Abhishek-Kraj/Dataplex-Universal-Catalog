output "profiling_scans" {
  description = "Map of profiling scan IDs to their details"
  value = {
    for k, v in google_dataplex_datascan.profiling_scans : k => {
      id           = v.id
      name         = v.name
      uid          = v.uid
      display_name = v.display_name
      state        = v.state
      type         = v.type
    }
  }
}

output "profiling_results_dataset_id" {
  description = "BigQuery dataset ID for profiling results"
  value       = google_bigquery_dataset.profiling_results.dataset_id
}

output "profiling_metrics_table_id" {
  description = "BigQuery table ID for profiling metrics"
  value       = google_bigquery_table.profiling_metrics.table_id
}

output "profiling_summary_table_id" {
  description = "BigQuery table ID for profiling summary"
  value       = google_bigquery_table.profiling_summary.table_id
}

output "latest_profiling_view_id" {
  description = "BigQuery view ID for latest profiling results"
  value       = google_bigquery_table.latest_profiling_view.table_id
}

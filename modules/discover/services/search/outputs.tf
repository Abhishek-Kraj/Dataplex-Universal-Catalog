output "search_config" {
  description = "Search configuration details"
  value = {
    scope           = var.search_scope
    result_limit    = var.search_result_limit
    dataset_id      = google_bigquery_dataset.search_results.dataset_id
    search_table_id = google_bigquery_table.search_history.table_id
  }
}

output "search_dataset_id" {
  description = "BigQuery dataset ID for search results"
  value       = google_bigquery_dataset.search_results.dataset_id
}

output "search_history_table_id" {
  description = "BigQuery table ID for search history"
  value       = google_bigquery_table.search_history.table_id
}

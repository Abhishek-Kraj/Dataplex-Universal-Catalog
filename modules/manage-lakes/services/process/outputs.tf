output "spark_jobs" {
  description = "Map of Spark job IDs to their details"
  value = {
    for k, v in google_dataplex_task.spark_jobs : k => {
      id           = v.id
      name         = v.name
      uid          = v.uid
      display_name = v.display_name
      state        = v.state
    }
  }
}

output "task_ids" {
  description = "Map of task IDs"
  value = merge(
    { for k, v in google_dataplex_task.spark_jobs : k => v.id },
    length(google_dataplex_task.data_quality_check) > 0 ? {
      data_quality_check = google_dataplex_task.data_quality_check[0].id
    } : {},
    length(google_dataplex_task.data_profiling) > 0 ? {
      data_profiling = google_dataplex_task.data_profiling[0].id
    } : {},
    length(google_dataplex_task.data_analysis_notebook) > 0 ? {
      data_analysis_notebook = google_dataplex_task.data_analysis_notebook[0].id
    } : {}
  )
}

output "spark_service_account_email" {
  description = "Spark runner service account email"
  value       = google_service_account.spark_runner.email
}

output "spark_artifacts_bucket" {
  description = "GCS bucket for Spark artifacts"
  value       = google_storage_bucket.spark_artifacts.name
}

output "spark_results_dataset_id" {
  description = "BigQuery dataset ID for Spark results"
  value       = google_bigquery_dataset.spark_results.dataset_id
}

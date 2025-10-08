output "lakes" {
  description = "Map of lake IDs to their details"
  value       = google_dataplex_lake.lakes
}

output "zones" {
  description = "Map of zone IDs to their details"
  value       = google_dataplex_zone.zones
}

output "assets" {
  description = "Map of asset IDs to their details"
  value = merge(
    google_dataplex_asset.gcs_assets,
    google_dataplex_asset.bigquery_assets
  )
}

output "iam_bindings" {
  description = "IAM binding details"
  value       = google_dataplex_lake_iam_member.bindings
}

output "tasks" {
  description = "Map of Dataplex task IDs to their details"
  value = merge(
    google_dataplex_task.spark_jobs,
    {
      for task in concat(
        google_dataplex_task.data_quality_check,
        google_dataplex_task.data_profiling,
        google_dataplex_task.data_analysis_notebook
      ) : task.task_id => task
    }
  )
}

output "service_accounts" {
  description = "Service accounts created for Dataplex operations"
  value = {
    dataplex_sa  = try(google_service_account.dataplex_sa[0], null)
    spark_runner = try(google_service_account.spark_runner[0], null)
  }
}

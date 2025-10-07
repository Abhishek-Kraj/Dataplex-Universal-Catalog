output "iam_bindings" {
  description = "IAM binding details"
  value = {
    for k, v in google_dataplex_lake_iam_member.bindings : k => {
      lake   = v.lake
      role   = v.role
      member = v.member
    }
  }
}

output "service_account_email" {
  description = "Dataplex service account email"
  value       = google_service_account.dataplex_sa.email
}

output "service_account_id" {
  description = "Dataplex service account ID"
  value       = google_service_account.dataplex_sa.id
}

output "kms_key_ring_id" {
  description = "KMS key ring ID"
  value       = google_kms_key_ring.dataplex.id
}

output "kms_crypto_key_id" {
  description = "KMS crypto key ID for data encryption"
  value       = google_kms_crypto_key.dataplex_data.id
}

output "security_logs_dataset_id" {
  description = "BigQuery dataset ID for security logs"
  value       = google_bigquery_dataset.security_logs.dataset_id
}

output "logging_sink_id" {
  description = "Logging sink ID for security events"
  value       = google_logging_project_sink.dataplex_security_sink.id
}

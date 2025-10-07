output "dashboards" {
  description = "Map of monitoring dashboard IDs"
  value = {
    dataplex_overview = google_monitoring_dashboard.dataplex_overview.id
  }
}

output "alert_policies" {
  description = "Map of alert policy IDs"
  value = {
    quality_failures = google_monitoring_alert_policy.quality_failures.id
    scan_failures    = google_monitoring_alert_policy.scan_failures.id
    lake_health      = google_monitoring_alert_policy.lake_health.id
  }
}

output "notification_channels" {
  description = "Map of notification channel IDs"
  value = {
    email = google_monitoring_notification_channel.email.id
  }
}

output "slo_id" {
  description = "Data quality SLO ID"
  value       = google_monitoring_slo.data_quality_slo.id
}

output "custom_service_id" {
  description = "Custom service ID for SLO"
  value       = google_monitoring_custom_service.dataplex.id
}

output "log_metrics" {
  description = "Map of log-based metric IDs"
  value = {
    quality_failures = google_logging_metric.quality_failures.id
  }
}

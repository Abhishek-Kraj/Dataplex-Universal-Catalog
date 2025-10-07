# Monitoring Service - Dashboards and Alerting

# Create notification channel for alerts
resource "google_monitoring_notification_channel" "email" {
  display_name = "Dataplex Email Notifications"
  type         = "email"
  project      = var.project_id

  labels = {
    email_address = "dataplex-alerts@example.com"
  }

  enabled = true
}

# Alert policy for data quality failures
resource "google_monitoring_alert_policy" "quality_failures" {
  display_name = "Dataplex - Data Quality Failures"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "Data quality score below threshold"

    condition_threshold {
      filter          = "resource.type=\"dataplex.googleapis.com/DataScan\" AND metric.type=\"dataplex.googleapis.com/data_scan/quality_score\""
      duration        = "300s"
      comparison      = "COMPARISON_LT"
      threshold_value = 0.80

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.id]

  alert_strategy {
    auto_close = "1800s"
  }

  documentation {
    content   = "Data quality score has fallen below 80%. Please investigate the failed quality rules and take corrective action."
    mime_type = "text/markdown"
  }

  enabled = true
}

# Alert policy for scan failures
resource "google_monitoring_alert_policy" "scan_failures" {
  display_name = "Dataplex - Scan Failures"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "Data scan execution failures"

    condition_threshold {
      filter          = "resource.type=\"dataplex.googleapis.com/DataScan\" AND metric.type=\"dataplex.googleapis.com/data_scan/execution_count\" AND metric.label.state=\"FAILED\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0

      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_SUM"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.id]

  documentation {
    content   = "One or more data scans have failed. Check the scan logs for error details."
    mime_type = "text/markdown"
  }

  enabled = true
}

# Alert policy for lake health
resource "google_monitoring_alert_policy" "lake_health" {
  display_name = "Dataplex - Lake Health Issues"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "Lake in unhealthy state"

    condition_threshold {
      filter          = "resource.type=\"dataplex.googleapis.com/Lake\" AND metric.type=\"dataplex.googleapis.com/lake/asset_count\" AND metric.label.state=\"UNHEALTHY\""
      duration        = "600s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0

      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MAX"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.id]

  documentation {
    content   = "One or more lakes are in an unhealthy state. Review lake configuration and asset status."
    mime_type = "text/markdown"
  }

  enabled = true
}

# Create monitoring dashboard
resource "google_monitoring_dashboard" "dataplex_overview" {
  dashboard_json = jsonencode({
    displayName = "Dataplex Overview Dashboard"

    mosaicLayout = {
      columns = 12
      tiles = [
        # Data Quality Score
        {
          width  = 4
          height = 4
          widget = {
            title = "Data Quality Score"
            scorecard = {
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type=\"dataplex.googleapis.com/DataScan\" AND metric.type=\"dataplex.googleapis.com/data_scan/quality_score\""
                  aggregation = {
                    alignmentPeriod  = "3600s"
                    perSeriesAligner = "ALIGN_MEAN"
                  }
                }
              }
              sparkChartView = {
                sparkChartType = "SPARK_LINE"
              }
              thresholds = [
                {
                  value     = 0.80
                  color     = "YELLOW"
                  direction = "BELOW"
                },
                {
                  value     = 0.90
                  color     = "RED"
                  direction = "BELOW"
                }
              ]
            }
          }
        },
        # Scan Execution Count
        {
          width  = 4
          height = 4
          yPos   = 0
          xPos   = 4
          widget = {
            title = "Scan Executions (24h)"
            scorecard = {
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type=\"dataplex.googleapis.com/DataScan\" AND metric.type=\"dataplex.googleapis.com/data_scan/execution_count\""
                  aggregation = {
                    alignmentPeriod  = "86400s"
                    perSeriesAligner = "ALIGN_SUM"
                  }
                }
              }
            }
          }
        },
        # Lake Asset Count
        {
          width  = 4
          height = 4
          yPos   = 0
          xPos   = 8
          widget = {
            title = "Total Assets"
            scorecard = {
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type=\"dataplex.googleapis.com/Lake\" AND metric.type=\"dataplex.googleapis.com/lake/asset_count\""
                  aggregation = {
                    alignmentPeriod    = "3600s"
                    perSeriesAligner   = "ALIGN_MEAN"
                    crossSeriesReducer = "REDUCE_SUM"
                  }
                }
              }
            }
          }
        },
        # Quality Score Trend
        {
          width  = 6
          height = 4
          yPos   = 4
          widget = {
            title = "Quality Score Trend (7 days)"
            xyChart = {
              dataSets = [
                {
                  timeSeriesQuery = {
                    timeSeriesFilter = {
                      filter = "resource.type=\"dataplex.googleapis.com/DataScan\" AND metric.type=\"dataplex.googleapis.com/data_scan/quality_score\""
                      aggregation = {
                        alignmentPeriod  = "3600s"
                        perSeriesAligner = "ALIGN_MEAN"
                      }
                    }
                  }
                  plotType = "LINE"
                }
              ]
              timeshiftDuration = "0s"
              yAxis = {
                label = "Quality Score"
                scale = "LINEAR"
              }
            }
          }
        },
        # Failed Rules
        {
          width  = 6
          height = 4
          yPos   = 4
          xPos   = 6
          widget = {
            title = "Failed Quality Rules"
            xyChart = {
              dataSets = [
                {
                  timeSeriesQuery = {
                    timeSeriesFilter = {
                      filter = "resource.type=\"dataplex.googleapis.com/DataScan\" AND metric.type=\"dataplex.googleapis.com/data_scan/rule_count\" AND metric.label.result=\"FAILED\""
                      aggregation = {
                        alignmentPeriod    = "3600s"
                        perSeriesAligner   = "ALIGN_SUM"
                        crossSeriesReducer = "REDUCE_SUM"
                      }
                    }
                  }
                  plotType = "STACKED_AREA"
                }
              ]
            }
          }
        },
        # Scan Duration
        {
          width  = 6
          height = 4
          yPos   = 8
          widget = {
            title = "Scan Duration (seconds)"
            xyChart = {
              dataSets = [
                {
                  timeSeriesQuery = {
                    timeSeriesFilter = {
                      filter = "resource.type=\"dataplex.googleapis.com/DataScan\" AND metric.type=\"dataplex.googleapis.com/data_scan/execution_time\""
                      aggregation = {
                        alignmentPeriod  = "3600s"
                        perSeriesAligner = "ALIGN_MEAN"
                      }
                    }
                  }
                  plotType = "LINE"
                }
              ]
            }
          }
        },
        # Data Freshness
        {
          width  = 6
          height = 4
          yPos   = 8
          xPos   = 6
          widget = {
            title = "Data Freshness (hours since last update)"
            xyChart = {
              dataSets = [
                {
                  timeSeriesQuery = {
                    timeSeriesFilter = {
                      filter = "resource.type=\"dataplex.googleapis.com/Lake\" AND metric.type=\"dataplex.googleapis.com/lake/data_freshness\""
                      aggregation = {
                        alignmentPeriod  = "3600s"
                        perSeriesAligner = "ALIGN_MAX"
                      }
                    }
                  }
                  plotType = "LINE"
                }
              ]
            }
          }
        }
      ]
    }
  })

  project = var.project_id
}

# Create SLO for data quality
resource "google_monitoring_slo" "data_quality_slo" {
  service      = google_monitoring_custom_service.dataplex.service_id
  slo_id       = "data-quality-slo"
  display_name = "Data Quality SLO - 95% Quality Score"
  project      = var.project_id

  goal                = 0.95
  rolling_period_days = 30

  request_based_sli {
    good_total_ratio {
      good_service_filter = "resource.type=\"dataplex.googleapis.com/DataScan\" AND metric.type=\"dataplex.googleapis.com/data_scan/quality_score\" AND metric.label.score >= 0.90"
      total_service_filter = "resource.type=\"dataplex.googleapis.com/DataScan\" AND metric.type=\"dataplex.googleapis.com/data_scan/quality_score\""
    }
  }
}

# Create custom service for SLO
resource "google_monitoring_custom_service" "dataplex" {
  service_id   = "dataplex-service"
  display_name = "Dataplex Service"
  project      = var.project_id
}

# Create log-based metric for quality failures
resource "google_logging_metric" "quality_failures" {
  name    = "dataplex/quality_failures"
  project = var.project_id
  filter  = <<-EOT
    resource.type="dataplex.googleapis.com/DataScan"
    AND jsonPayload.quality_result.passed = false
  EOT

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
    display_name = "Data Quality Failures"

    labels {
      key         = "scan_id"
      value_type  = "STRING"
      description = "Data scan ID"
    }

    labels {
      key         = "rule_type"
      value_type  = "STRING"
      description = "Quality rule type"
    }
  }

  label_extractors = {
    "scan_id"   = "EXTRACT(resource.labels.datascan_id)"
    "rule_type" = "EXTRACT(jsonPayload.quality_result.rule_type)"
  }
}

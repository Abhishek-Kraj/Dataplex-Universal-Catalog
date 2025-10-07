# ==============================================================================
# DATAPLEX GOVERN MODULE
# ==============================================================================
# This module manages data quality scans, profiling, and monitoring
# All resources are controlled via variables - use enable_* flags to toggle features
# ==============================================================================

# ==============================================================================
# DATA QUALITY SCANS
# ==============================================================================

# Quality Service - Data Quality Checks and Rules

# Create Data Quality Scans
resource "google_dataplex_datascan" "quality_scans" {
  for_each = { for scan in var.quality_scans : scan.scan_id => scan }

  location     = var.location
  data_scan_id = each.value.scan_id
  project      = var.project_id
  display_name = coalesce(each.value.display_name, each.value.scan_id)
  description  = coalesce(each.value.description, "Data quality scan for ${each.value.data_source}")

  data {
    resource = each.value.data_source
  }

  execution_spec {
    trigger {
      schedule {
        cron = "0 */6 * * *" # Every 6 hours
      }
    }
  }

  data_quality_spec {
    sampling_percent = 100
    row_filter       = ""

    # Define quality rules
    dynamic "rules" {
      for_each = coalesce(each.value.rules, [])
      content {
        dimension = rules.value.dimension

        # Non-null rule
        dynamic "non_null_expectation" {
          for_each = rules.value.rule_type == "NON_NULL" ? [1] : []
          content {}
        }

        # Range rule
        dynamic "range_expectation" {
          for_each = rules.value.rule_type == "RANGE" ? [1] : []
          content {
            min_value = "0"
            max_value = "100"
          }
        }

        # Regex rule
        dynamic "regex_expectation" {
          for_each = rules.value.rule_type == "REGEX" ? [1] : []
          content {
            regex = "^[a-zA-Z0-9_]+$"
          }
        }

        # Set expectation
        dynamic "set_expectation" {
          for_each = rules.value.rule_type == "SET" ? [1] : []
          content {
            values = ["ACTIVE", "INACTIVE", "PENDING"]
          }
        }

        # Uniqueness rule
        dynamic "uniqueness_expectation" {
          for_each = rules.value.rule_type == "UNIQUENESS" ? [1] : []
          content {}
        }

        # Column specified if provided
        column = rules.value.column != null ? rules.value.column : null

        threshold = rules.value.threshold
      }
    }

    # Default completeness rules
    rules {
      dimension = "COMPLETENESS"
      non_null_expectation {}
      threshold = 0.95
    }

    rules {
      dimension = "VALIDITY"
      threshold = 0.90
    }

    rules {
      dimension = "CONSISTENCY"
      threshold = 0.95
    }
  }

  labels = merge(
    var.labels,
    {
      module  = "govern"
      service = "quality"
      lake_id = each.value.lake_id
    }
  )

}

# Create BigQuery dataset for quality results
resource "google_bigquery_dataset" "quality_results" {
  dataset_id  = "dataplex_quality_results"
  project     = var.project_id
  location    = var.location
  description = "Dataset for data quality scan results and metrics"

  labels = merge(
    var.labels,
    {
      module  = "govern"
      service = "quality"
    }
  )

  delete_contents_on_destroy = false
}

# Create table for quality scan results
resource "google_bigquery_table" "quality_scan_results" {
  dataset_id          = google_bigquery_dataset.quality_results.dataset_id
  table_id            = "quality_scan_results"
  project             = var.project_id
  deletion_protection = false

  schema = jsonencode([
    {
      name = "scan_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "data_source"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "scan_timestamp"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    },
    {
      name = "passed_rules"
      type = "INTEGER"
      mode = "NULLABLE"
    },
    {
      name = "failed_rules"
      type = "INTEGER"
      mode = "NULLABLE"
    },
    {
      name = "total_rules"
      type = "INTEGER"
      mode = "NULLABLE"
    },
    {
      name = "overall_score"
      type = "FLOAT"
      mode = "NULLABLE"
    },
    {
      name = "completeness_score"
      type = "FLOAT"
      mode = "NULLABLE"
    },
    {
      name = "accuracy_score"
      type = "FLOAT"
      mode = "NULLABLE"
    },
    {
      name = "validity_score"
      type = "FLOAT"
      mode = "NULLABLE"
    },
    {
      name = "consistency_score"
      type = "FLOAT"
      mode = "NULLABLE"
    },
    {
      name = "scan_status"
      type = "STRING"
      mode = "NULLABLE"
    }
  ])

  labels = merge(
    var.labels,
    {
      module  = "govern"
      service = "quality"
    }
  )
}

# Create table for quality rule details
resource "google_bigquery_table" "quality_rule_results" {
  dataset_id          = google_bigquery_dataset.quality_results.dataset_id
  table_id            = "quality_rule_results"
  project             = var.project_id
  deletion_protection = false

  schema = jsonencode([
    {
      name = "scan_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "rule_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "rule_type"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "dimension"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "column_name"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "threshold"
      type = "FLOAT"
      mode = "NULLABLE"
    },
    {
      name = "actual_value"
      type = "FLOAT"
      mode = "NULLABLE"
    },
    {
      name = "passed"
      type = "BOOLEAN"
      mode = "REQUIRED"
    },
    {
      name = "failure_count"
      type = "INTEGER"
      mode = "NULLABLE"
    },
    {
      name = "evaluated_count"
      type = "INTEGER"
      mode = "NULLABLE"
    },
    {
      name = "scan_timestamp"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    }
  ])

  labels = merge(
    var.labels,
    {
      module  = "govern"
      service = "quality"
    }
  )
}

# Create view for quality trends
resource "google_bigquery_table" "quality_trends_view" {
  dataset_id          = google_bigquery_dataset.quality_results.dataset_id
  table_id            = "quality_trends"
  project             = var.project_id
  deletion_protection = false

  view {
    query = <<-SQL
      SELECT
        scan_id,
        data_source,
        DATE(scan_timestamp) as scan_date,
        AVG(overall_score) as avg_quality_score,
        AVG(completeness_score) as avg_completeness,
        AVG(accuracy_score) as avg_accuracy,
        AVG(validity_score) as avg_validity,
        AVG(consistency_score) as avg_consistency,
        COUNT(*) as scan_count,
        SUM(failed_rules) as total_failures
      FROM `${var.project_id}.${google_bigquery_dataset.quality_results.dataset_id}.quality_scan_results`
      WHERE scan_timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
      GROUP BY scan_id, data_source, scan_date
      ORDER BY scan_date DESC, scan_id
    SQL

    use_legacy_sql = false
  }

  labels = merge(
    var.labels,
    {
      module  = "govern"
      service = "quality"
    }
  )
}

# Create view for failed quality rules
resource "google_bigquery_table" "failed_rules_view" {
  dataset_id          = google_bigquery_dataset.quality_results.dataset_id
  table_id            = "failed_quality_rules"
  project             = var.project_id
  deletion_protection = false

  view {
    query = <<-SQL
      SELECT
        r.scan_id,
        r.rule_id,
        r.rule_type,
        r.dimension,
        r.column_name,
        r.threshold,
        r.actual_value,
        r.failure_count,
        r.evaluated_count,
        r.scan_timestamp,
        s.data_source
      FROM `${var.project_id}.${google_bigquery_dataset.quality_results.dataset_id}.quality_rule_results` r
      INNER JOIN `${var.project_id}.${google_bigquery_dataset.quality_results.dataset_id}.quality_scan_results` s
        ON r.scan_id = s.scan_id
        AND r.scan_timestamp = s.scan_timestamp
      WHERE r.passed = FALSE
        AND r.scan_timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
      ORDER BY r.scan_timestamp DESC, r.failure_count DESC
    SQL

    use_legacy_sql = false
  }

  labels = merge(
    var.labels,
    {
      module  = "govern"
      service = "quality"
    }
  )
}
# Profiling Service - Data Profiling and Discovery

# Create Data Profiling Scans using Dataplex Data Scan API
resource "google_dataplex_datascan" "profiling_scans" {
  for_each = { for scan in var.profiling_scans : scan.scan_id => scan }

  location     = var.location
  data_scan_id = each.value.scan_id
  project      = var.project_id
  display_name = coalesce(each.value.display_name, each.value.scan_id)
  description  = coalesce(each.value.description, "Data profiling scan for ${each.value.data_source}")

  data {
    resource = each.value.data_source
  }

  execution_spec {
    trigger {
      schedule {
        cron = "0 2 * * *" # Daily at 2 AM
      }
    }
  }

  data_profile_spec {
    # Profile all columns
    sampling_percent = 100
    row_filter       = ""
  }

  labels = merge(
    var.labels,
    {
      module  = "govern"
      service = "profiling"
      lake_id = each.value.lake_id
    }
  )

}

# Create BigQuery dataset for profiling results
resource "google_bigquery_dataset" "profiling_results" {
  dataset_id  = "dataplex_profiling_results"
  project     = var.project_id
  location    = var.location
  description = "Dataset for data profiling results and statistics"

  labels = merge(
    var.labels,
    {
      module  = "govern"
      service = "profiling"
    }
  )

  delete_contents_on_destroy = false
}

# Create table for profiling metrics
resource "google_bigquery_table" "profiling_metrics" {
  dataset_id          = google_bigquery_dataset.profiling_results.dataset_id
  table_id            = "profiling_metrics"
  project             = var.project_id
  deletion_protection = false

  schema = jsonencode([
    {
      name = "scan_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "data_source"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "column_name"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "data_type"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "null_count"
      type = "INTEGER"
      mode = "NULLABLE"
    },
    {
      name = "null_percentage"
      type = "FLOAT"
      mode = "NULLABLE"
    },
    {
      name = "distinct_count"
      type = "INTEGER"
      mode = "NULLABLE"
    },
    {
      name = "min_value"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "max_value"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "mean_value"
      type = "FLOAT"
      mode = "NULLABLE"
    },
    {
      name = "median_value"
      type = "FLOAT"
      mode = "NULLABLE"
    },
    {
      name = "std_dev"
      type = "FLOAT"
      mode = "NULLABLE"
    },
    {
      name = "scan_timestamp"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    }
  ])

  labels = merge(
    var.labels,
    {
      module  = "govern"
      service = "profiling"
    }
  )
}

# Create table for profiling summaries
resource "google_bigquery_table" "profiling_summary" {
  dataset_id          = google_bigquery_dataset.profiling_results.dataset_id
  table_id            = "profiling_summary"
  project             = var.project_id
  deletion_protection = false

  schema = jsonencode([
    {
      name = "scan_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "data_source"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "total_rows"
      type = "INTEGER"
      mode = "NULLABLE"
    },
    {
      name = "total_columns"
      type = "INTEGER"
      mode = "NULLABLE"
    },
    {
      name = "profiled_columns"
      type = "INTEGER"
      mode = "NULLABLE"
    },
    {
      name = "data_freshness"
      type = "TIMESTAMP"
      mode = "NULLABLE"
    },
    {
      name = "scan_status"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "scan_duration_seconds"
      type = "FLOAT"
      mode = "NULLABLE"
    },
    {
      name = "scan_timestamp"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    }
  ])

  labels = merge(
    var.labels,
    {
      module  = "govern"
      service = "profiling"
    }
  )
}

# Create view for latest profiling results
resource "google_bigquery_table" "latest_profiling_view" {
  dataset_id          = google_bigquery_dataset.profiling_results.dataset_id
  table_id            = "latest_profiling_results"
  project             = var.project_id
  deletion_protection = false

  view {
    query = <<-SQL
      SELECT
        m.*,
        s.total_rows,
        s.scan_status
      FROM `${var.project_id}.${google_bigquery_dataset.profiling_results.dataset_id}.profiling_metrics` m
      INNER JOIN (
        SELECT
          scan_id,
          column_name,
          MAX(scan_timestamp) as latest_scan
        FROM `${var.project_id}.${google_bigquery_dataset.profiling_results.dataset_id}.profiling_metrics`
        GROUP BY scan_id, column_name
      ) latest
        ON m.scan_id = latest.scan_id
        AND m.column_name = latest.column_name
        AND m.scan_timestamp = latest.latest_scan
      LEFT JOIN `${var.project_id}.${google_bigquery_dataset.profiling_results.dataset_id}.profiling_summary` s
        ON m.scan_id = s.scan_id
        AND m.scan_timestamp = s.scan_timestamp
      ORDER BY m.scan_timestamp DESC
    SQL

    use_legacy_sql = false
  }

  labels = merge(
    var.labels,
    {
      module  = "govern"
      service = "profiling"
    }
  )
}
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

# Quality Service - Data Quality Checks and Rules

# Data source to get existing lakes
data "google_dataplex_lake" "lakes" {
  for_each = toset([for scan in var.quality_scans : scan.lake_id])

  lake     = each.value
  location = var.location
  project  = var.project_id
}

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

  depends_on = [data.google_dataplex_lake.lakes]
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

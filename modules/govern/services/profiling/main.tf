# Profiling Service - Data Profiling and Discovery

# Data source to get existing lakes
data "google_dataplex_lake" "lakes" {
  for_each = toset([for scan in var.profiling_scans : scan.lake_id])

  lake     = each.value
  location = var.location
  project  = var.project_id
}

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

  depends_on = [data.google_dataplex_lake.lakes]
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

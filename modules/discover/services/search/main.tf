# Search Service - Dataplex Search Configuration

# Note: Dataplex search is primarily accessed via API/Console
# This module configures search-related metadata and saved searches

locals {
  search_config = {
    scope        = var.search_scope
    result_limit = var.search_result_limit
    project_id   = var.project_id
    location     = var.location
  }
}

# Example: Create a BigQuery dataset for storing search results/metadata
resource "google_bigquery_dataset" "search_results" {
  dataset_id  = var.search_dataset_id
  project     = var.project_id
  location    = var.location
  description = "Dataset for storing Dataplex search results and metadata"

  labels = merge(
    var.labels,
    {
      module  = "discover"
      service = "search"
    }
  )

  default_table_expiration_ms = var.search_history_retention_days * 24 * 60 * 60 * 1000
  delete_contents_on_destroy  = false
}

# Create a table for storing search history
resource "google_bigquery_table" "search_history" {
  count = var.enable_search_history ? 1 : 0

  dataset_id          = google_bigquery_dataset.search_results.dataset_id
  table_id            = "search_history"
  project             = var.project_id
  deletion_protection = false

  schema = jsonencode([
    {
      name = "search_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "search_query"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "search_scope"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "result_count"
      type = "INTEGER"
      mode = "NULLABLE"
    },
    {
      name = "timestamp"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    },
    {
      name = "user_email"
      type = "STRING"
      mode = "NULLABLE"
    }
  ])

  labels = merge(
    var.labels,
    {
      module  = "discover"
      service = "search"
    }
  )
}

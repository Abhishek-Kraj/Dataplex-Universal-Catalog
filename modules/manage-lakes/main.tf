# ==============================================================================
# DATAPLEX MANAGE LAKES MODULE
# ==============================================================================
# This module manages Dataplex lakes, zones, assets, IAM, and processing tasks
# All resources are controlled via variables - use enable_* flags to toggle features
# ==============================================================================

# ==============================================================================
# MANAGE: LAKES, ZONES, AND ASSETS
# ==============================================================================

# Create Dataplex Lakes
resource "google_dataplex_lake" "lakes" {
  for_each = var.enable_manage ? { for lake in var.lakes : lake.lake_id => lake } : {}

  name         = each.value.lake_id
  location     = var.location
  project      = var.project_id
  display_name = coalesce(each.value.display_name, each.value.lake_id)
  description  = coalesce(each.value.description, "Dataplex lake: ${each.value.lake_id}")

  labels = merge(
    var.labels,
    each.value.labels,
    {
      module = "manage-lakes"
    }
  )
}

# Flatten zones from all lakes
locals {
  zones = var.enable_manage ? flatten([
    for lake in var.lakes : [
      for zone in coalesce(lake.zones, []) : {
        zone_id          = zone.zone_id
        lake_id          = lake.lake_id
        type             = zone.type
        display_name     = zone.display_name
        description      = zone.description
        location_type    = zone.location_type
        existing_bucket  = zone.existing_bucket
        existing_dataset = zone.existing_dataset
        create_storage   = coalesce(zone.create_storage, true)
        # Custom names for new resources
        bucket_name      = zone.bucket_name
        dataset_id       = zone.dataset_id
      }
    ]
  ]) : []

  zones_map = {
    for zone in local.zones : "${zone.lake_id}-${zone.zone_id}" => zone
  }

  # Zones that need new storage created
  zones_needing_storage = {
    for k, v in local.zones_map : k => v
    if v.create_storage == true
  }

  # Zones using existing storage
  zones_using_existing = {
    for k, v in local.zones_map : k => v
    if v.create_storage == false
  }
}

# Create Dataplex Zones
resource "google_dataplex_zone" "zones" {
  for_each = local.zones_map

  lake         = google_dataplex_lake.lakes[each.value.lake_id].id
  location     = var.location
  name         = each.value.zone_id
  type         = each.value.type
  display_name = coalesce(each.value.display_name, each.value.zone_id)
  description  = coalesce(each.value.description, "${each.value.type} zone: ${each.value.zone_id}")

  resource_spec {
    location_type = each.value.location_type
  }

  discovery_spec {
    enabled  = true
    schedule = "0 * * * *" # Hourly discovery
  }

  labels = merge(
    var.labels,
    {
      module  = "manage-lakes"
      lake_id = each.value.lake_id
    }
  )
}

# Data source for existing GCS buckets (RAW zones)
data "google_storage_bucket" "existing_raw_buckets" {
  for_each = {
    for k, v in local.zones_using_existing : k => v
    if v.type == "RAW" && v.existing_bucket != null
  }

  name = each.value.existing_bucket
}

# Create GCS bucket for RAW zones (only if create_storage = true)
resource "google_storage_bucket" "raw_zone_bucket" {
  for_each = {
    for k, v in local.zones_needing_storage : k => v
    if v.type == "RAW"
  }

  name     = coalesce(each.value.bucket_name, "${var.project_id}-${each.value.lake_id}-${each.value.zone_id}")
  location = var.location
  project  = var.project_id

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }

  labels = merge(
    var.labels,
    {
      module    = "manage-lakes"
      zone_type = "raw"
      lake_id   = each.value.lake_id
    }
  )
}

# Data source for existing BigQuery datasets (CURATED zones)
data "google_bigquery_dataset" "existing_curated_datasets" {
  for_each = {
    for k, v in local.zones_using_existing : k => v
    if v.type == "CURATED" && v.existing_dataset != null
  }

  dataset_id = each.value.existing_dataset
  project    = var.project_id
}

# Create BigQuery dataset for CURATED zones (only if create_storage = true)
resource "google_bigquery_dataset" "curated_zone_dataset" {
  for_each = {
    for k, v in local.zones_needing_storage : k => v
    if v.type == "CURATED"
  }

  dataset_id  = coalesce(each.value.dataset_id, replace("${each.value.lake_id}_${each.value.zone_id}", "-", "_"))
  project     = var.project_id
  location    = var.location
  description = "Curated zone dataset for ${each.value.lake_id}"

  labels = merge(
    var.labels,
    {
      module    = "manage-lakes"
      zone_type = "curated"
      lake_id   = each.value.lake_id
    }
  )

  delete_contents_on_destroy = false
}

# Create Dataplex Assets for GCS buckets (RAW zones)
resource "google_dataplex_asset" "raw_assets" {
  for_each = {
    for k, v in local.zones_map : k => v
    if v.type == "RAW"
  }

  name          = replace("${each.value.lake_id}-${each.value.zone_id}-asset", "_", "-")
  lake          = google_dataplex_lake.lakes[each.value.lake_id].id
  location      = var.location
  dataplex_zone = google_dataplex_zone.zones[each.key].id
  display_name  = "${each.value.lake_id} ${each.value.zone_id} Asset"
  description   = "Asset for RAW zone ${each.value.zone_id}"

  resource_spec {
    name = each.value.create_storage ? (
      "projects/${var.project_id}/buckets/${google_storage_bucket.raw_zone_bucket[each.key].name}"
    ) : (
      "projects/${var.project_id}/buckets/${each.value.existing_bucket}"
    )
    type = "STORAGE_BUCKET"
  }

  discovery_spec {
    enabled  = true
    schedule = "0 * * * *" # Hourly discovery
  }

  labels = merge(
    var.labels,
    {
      module     = "manage-lakes"
      asset_type = "gcs-bucket"
    }
  )
}

# Create Dataplex Assets for BigQuery datasets (CURATED zones)
resource "google_dataplex_asset" "curated_assets" {
  for_each = {
    for k, v in local.zones_map : k => v
    if v.type == "CURATED"
  }

  name          = replace("${each.value.lake_id}-${each.value.zone_id}-asset", "_", "-")
  lake          = google_dataplex_lake.lakes[each.value.lake_id].id
  location      = var.location
  dataplex_zone = google_dataplex_zone.zones[each.key].id
  display_name  = "${each.value.lake_id} ${each.value.zone_id} Asset"
  description   = "Asset for CURATED zone ${each.value.zone_id}"

  resource_spec {
    name = each.value.create_storage ? (
      "projects/${var.project_id}/datasets/${google_bigquery_dataset.curated_zone_dataset[each.key].dataset_id}"
    ) : (
      "projects/${var.project_id}/datasets/${each.value.existing_dataset}"
    )
    type = "BIGQUERY_DATASET"
  }

  discovery_spec {
    enabled  = true
    schedule = "0 * * * *" # Hourly discovery
  }

  labels = merge(
    var.labels,
    {
      module     = "manage-lakes"
      asset_type = "bigquery-dataset"
    }
  )
}

# ==============================================================================
# SECURE: IAM BINDINGS, ENCRYPTION, AUDIT LOGGING
# ==============================================================================

# IAM Bindings for Lakes
locals {
  # Expand IAM bindings to handle multiple members
  iam_bindings_expanded = var.enable_secure ? flatten([
    for binding in var.iam_bindings : [
      for member in binding.members : {
        lake_id = binding.lake_id
        role    = binding.role
        member  = member
      }
    ]
  ]) : []
}

resource "google_dataplex_lake_iam_member" "bindings" {
  for_each = {
    for idx, binding in local.iam_bindings_expanded :
    "${binding.lake_id}-${binding.role}-${idx}" => binding
  }

  project  = var.project_id
  location = var.location
  lake     = each.value.lake_id
  role     = each.value.role
  member   = each.value.member

  depends_on = [google_dataplex_lake.lakes]
}

# Create service account for Dataplex operations
resource "google_service_account" "dataplex_sa" {
  count = var.enable_secure ? 1 : 0

  account_id   = "dataplex-operations-sa"
  display_name = "Dataplex Operations Service Account"
  description  = "Service account for Dataplex data processing and governance operations"
  project      = var.project_id
}

# Grant necessary permissions to the service account
resource "google_project_iam_member" "dataplex_sa_roles" {
  for_each = var.enable_secure ? toset([
    "roles/dataplex.admin",
    "roles/datacatalog.admin",
    "roles/bigquery.dataEditor",
    "roles/storage.objectAdmin"
  ]) : toset([])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.dataplex_sa[0].email}"
}

# ==============================================================================
# SECURE: CUSTOMER-MANAGED ENCRYPTION (CMEK)
# ==============================================================================
# Note: Dataplex CMEK is configured at the ORGANIZATION level, not per resource
# Use: gcloud dataplex encryption-config create default --location=LOCATION --organization=ORG_ID --key=KEY_ID
# This module does not create KMS keys as they are not directly used by Dataplex resources

# Create IAM Conditions for time-based access
resource "google_dataplex_lake_iam_binding" "time_bound_access" {
  for_each = var.enable_secure ? toset([for binding in var.iam_bindings : binding.lake_id]) : toset([])

  project  = var.project_id
  location = var.location
  lake     = each.value
  role     = "roles/dataplex.viewer"

  members = [
    "serviceAccount:${google_service_account.dataplex_sa[0].email}",
  ]

  condition {
    title       = "Business hours access"
    description = "Access allowed only during business hours (9am-5pm)"
    expression  = <<-EOT
      request.time.getHours("America/New_York") >= 9 &&
      request.time.getHours("America/New_York") <= 17
    EOT
  }

  depends_on = [google_dataplex_lake.lakes]
}

# Create audit logging configuration
resource "google_project_iam_audit_config" "dataplex_audit" {
  count = var.enable_secure ? 1 : 0

  project = var.project_id
  service = "dataplex.googleapis.com"

  audit_log_config {
    log_type = "ADMIN_READ"
  }

  audit_log_config {
    log_type = "DATA_READ"
  }

  audit_log_config {
    log_type = "DATA_WRITE"
  }
}

# Create BigQuery dataset for security logs
resource "google_bigquery_dataset" "security_logs" {
  count = var.enable_secure ? 1 : 0

  dataset_id  = "dataplex_security_logs"
  project     = var.project_id
  location    = var.location
  description = "Security and audit logs for Dataplex operations"

  labels = merge(
    var.labels,
    {
      module  = "manage-lakes"
      purpose = "security-logs"
    }
  )

  default_table_expiration_ms = 7776000000 # 90 days
  delete_contents_on_destroy  = false
}

# Create logging sink for security events
resource "google_logging_project_sink" "dataplex_security_sink" {
  count = var.enable_secure ? 1 : 0

  name        = "dataplex-security-events"
  project     = var.project_id
  destination = "bigquery.googleapis.com/projects/${var.project_id}/datasets/${google_bigquery_dataset.security_logs[0].dataset_id}"

  filter = <<-EOT
    resource.type="dataplex.googleapis.com/Lake"
    AND (
      protoPayload.methodName=~".*IAM.*"
      OR protoPayload.methodName=~".*Delete.*"
      OR severity >= WARNING
    )
  EOT

  unique_writer_identity = true

  bigquery_options {
    use_partitioned_tables = true
  }
}

# Grant BigQuery data editor role to the log sink
resource "google_bigquery_dataset_iam_member" "sink_writer" {
  count = var.enable_secure ? 1 : 0

  dataset_id = google_bigquery_dataset.security_logs[0].dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = google_logging_project_sink.dataplex_security_sink[0].writer_identity
}

# ==============================================================================
# PROCESS: DATA PROCESSING TASKS AND SPARK JOBS
# ==============================================================================

# Create service account for Spark job execution
resource "google_service_account" "spark_runner" {
  count = var.enable_process ? 1 : 0

  account_id   = "dataplex-spark-runner"
  display_name = "Dataplex Spark Runner"
  description  = "Service account for running Dataplex Spark jobs"
  project      = var.project_id
}

# Grant necessary permissions to Spark service account
resource "google_project_iam_member" "spark_runner_roles" {
  for_each = var.enable_process ? toset([
    "roles/dataplex.editor",
    "roles/bigquery.dataEditor",
    "roles/storage.objectAdmin",
    "roles/dataproc.worker"
  ]) : toset([])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.spark_runner[0].email}"
}

# Create GCS bucket for Spark job artifacts and logs
resource "google_storage_bucket" "spark_artifacts" {
  count = var.enable_process ? 1 : 0

  name     = "${var.project_id}-dataplex-spark-artifacts"
  location = var.location
  project  = var.project_id

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type = "Delete"
    }
  }

  labels = merge(
    var.labels,
    {
      module  = "manage-lakes"
      purpose = "spark-artifacts"
    }
  )
}

# Grant Spark service account access to artifacts bucket
resource "google_storage_bucket_iam_member" "spark_artifacts_access" {
  count = var.enable_process ? 1 : 0

  bucket = google_storage_bucket.spark_artifacts[0].name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.spark_runner[0].email}"
}

# Create BigQuery dataset for Spark job results
resource "google_bigquery_dataset" "spark_results" {
  count = var.enable_process ? 1 : 0

  dataset_id  = "dataplex_spark_results"
  project     = var.project_id
  location    = var.location
  description = "Dataset for Dataplex Spark job results and intermediate data"

  labels = merge(
    var.labels,
    {
      module  = "manage-lakes"
      purpose = "spark-results"
    }
  )

  delete_contents_on_destroy = false
}

# Create Dataplex Tasks for user-defined Spark jobs
resource "google_dataplex_task" "spark_jobs" {
  for_each = var.enable_process ? { for job in var.spark_jobs : job.job_id => job } : {}

  task_id      = each.value.job_id
  location     = var.location
  lake         = each.value.lake_id
  project      = var.project_id
  display_name = coalesce(each.value.display_name, each.value.job_id)
  description  = coalesce(each.value.description, "Spark job: ${each.value.job_id}")

  trigger_spec {
    type = "ON_DEMAND"
  }

  execution_spec {
    service_account = google_service_account.spark_runner[0].email
    args = merge(
      {
        "spark.executor.instances" = "2"
        "spark.driver.memory"      = "4g"
        "spark.executor.memory"    = "4g"
      },
      { for idx, arg in coalesce(each.value.args, []) : "arg${idx}" => arg }
    )
  }

  spark {
    main_class        = each.value.main_class
    main_jar_file_uri = each.value.main_jar_uri

    infrastructure_spec {
      batch {
        executors_count     = 2
        max_executors_count = 5
      }
      vpc_network {
        network_tags = ["dataplex-spark"]
      }
    }
  }

  labels = merge(
    var.labels,
    {
      module  = "manage-lakes"
      lake_id = each.value.lake_id
    }
  )

  depends_on = [google_dataplex_lake.lakes]
}

# Create automated data quality check task
resource "google_dataplex_task" "data_quality_check" {
  count = var.enable_process && length(var.spark_jobs) > 0 ? 1 : 0

  task_id      = "data-quality-check"
  location     = var.location
  lake         = var.spark_jobs[0].lake_id
  project      = var.project_id
  display_name = "Data Quality Check Task"
  description  = "Automated data quality checks for lake assets"

  trigger_spec {
    type     = "RECURRING"
    schedule = "0 2 * * *" # Daily at 2 AM
  }

  execution_spec {
    service_account            = google_service_account.spark_runner[0].email
    max_job_execution_lifetime = "3600s"
  }

  spark {
    python_script_file = "gs://${google_storage_bucket.spark_artifacts[0].name}/scripts/data_quality_check.py"

    infrastructure_spec {
      batch {
        executors_count     = 2
        max_executors_count = 3
      }
    }
  }

  labels = merge(
    var.labels,
    {
      module = "manage-lakes"
      type   = "quality-check"
    }
  )

  depends_on = [google_dataplex_lake.lakes]
}

# Create automated data profiling task
resource "google_dataplex_task" "data_profiling" {
  count = var.enable_process && length(var.spark_jobs) > 0 ? 1 : 0

  task_id      = "data-profiling"
  location     = var.location
  lake         = var.spark_jobs[0].lake_id
  project      = var.project_id
  display_name = "Data Profiling Task"
  description  = "Automated data profiling for lake assets"

  trigger_spec {
    type     = "RECURRING"
    schedule = "0 3 * * 0" # Weekly on Sunday at 3 AM
  }

  execution_spec {
    service_account            = google_service_account.spark_runner[0].email
    max_job_execution_lifetime = "7200s"
  }

  spark {
    python_script_file = "gs://${google_storage_bucket.spark_artifacts[0].name}/scripts/data_profiling.py"

    infrastructure_spec {
      batch {
        executors_count     = 3
        max_executors_count = 5
      }
    }
  }

  labels = merge(
    var.labels,
    {
      module = "manage-lakes"
      type   = "profiling"
    }
  )

  depends_on = [google_dataplex_lake.lakes]
}

# Create notebook for interactive data analysis
resource "google_dataplex_task" "data_analysis_notebook" {
  count = var.enable_process && length(var.spark_jobs) > 0 ? 1 : 0

  task_id      = "data-analysis-notebook"
  location     = var.location
  lake         = var.spark_jobs[0].lake_id
  project      = var.project_id
  display_name = "Data Analysis Notebook"
  description  = "Interactive notebook for data analysis"

  trigger_spec {
    type = "ON_DEMAND"
  }

  execution_spec {
    service_account = google_service_account.spark_runner[0].email
  }

  notebook {
    notebook = "gs://${google_storage_bucket.spark_artifacts[0].name}/notebooks/analysis.ipynb"
    infrastructure_spec {
      batch {
        executors_count = 2
      }
    }
  }

  labels = merge(
    var.labels,
    {
      module = "manage-lakes"
      type   = "notebook"
    }
  )

  depends_on = [google_dataplex_lake.lakes]
}

# ==============================================================================
# PROCESS: SPARK SQL TASKS
# ==============================================================================

# Create Spark SQL tasks for SQL-based transformations
resource "google_dataplex_task" "spark_sql_jobs" {
  for_each = var.enable_process ? { for job in var.spark_sql_jobs : job.job_id => job } : {}

  task_id      = each.value.job_id
  location     = var.location
  lake         = each.value.lake_id
  project      = var.project_id
  display_name = coalesce(each.value.display_name, each.value.job_id)
  description  = coalesce(each.value.description, "Spark SQL job: ${each.value.job_id}")

  trigger_spec {
    type     = each.value.schedule != null ? "RECURRING" : "ON_DEMAND"
    schedule = each.value.schedule  # Cron format string, not a block
  }

  execution_spec {
    service_account = google_service_account.spark_runner[0].email
  }

  spark {
    # Either inline SQL script or file URI
    sql_script      = each.value.sql_script
    sql_script_file = each.value.sql_file_uri

    # Additional files and archives
    file_uris    = coalesce(each.value.file_uris, [])
    archive_uris = coalesce(each.value.archive_uris, [])

    infrastructure_spec {
      batch {
        executors_count     = 2
        max_executors_count = 5
      }
      vpc_network {
        network_tags = ["dataplex-spark"]
      }
    }
  }

  labels = merge(
    var.labels,
    {
      module  = "manage-lakes"
      lake_id = each.value.lake_id
      type    = "spark-sql"
    }
  )

  depends_on = [google_dataplex_lake.lakes]
}

# ==============================================================================
# PROCESS: NOTEBOOK TASKS  
# ==============================================================================

# Create Jupyter notebook tasks for interactive data analysis
resource "google_dataplex_task" "notebook_jobs" {
  for_each = var.enable_process ? { for job in var.notebook_jobs : job.job_id => job } : {}

  task_id      = each.value.job_id
  location     = var.location
  lake         = each.value.lake_id
  project      = var.project_id
  display_name = coalesce(each.value.display_name, each.value.job_id)
  description  = coalesce(each.value.description, "Notebook job: ${each.value.job_id}")

  trigger_spec {
    type     = each.value.schedule != null ? "RECURRING" : "ON_DEMAND"
    schedule = each.value.schedule  # Cron format string, not a block
  }

  execution_spec {
    service_account = google_service_account.spark_runner[0].email
  }

  notebook {
    notebook = each.value.notebook_uri

    # Additional files and archives
    file_uris    = coalesce(each.value.file_uris, [])
    archive_uris = coalesce(each.value.archive_uris, [])

    infrastructure_spec {
      batch {
        executors_count     = 2
        max_executors_count = 10
      }

      # Optional custom container image
      dynamic "container_image" {
        for_each = each.value.container_image != null ? [1] : []
        content {
          image = each.value.container_image
        }
      }

      vpc_network {
        network_tags = ["dataplex-spark"]
      }
    }
  }

  labels = merge(
    var.labels,
    {
      module  = "manage-lakes"
      lake_id = each.value.lake_id
      type    = "notebook"
    }
  )

  depends_on = [google_dataplex_lake.lakes]
}

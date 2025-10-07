# Process Service - Data Processing Tasks and Spark Jobs

# Data source to get existing lakes
data "google_dataplex_lake" "lakes" {
  for_each = toset([for job in var.spark_jobs : job.lake_id])

  lake     = each.value
  location = var.location
  project  = var.project_id
}

# Create Dataplex Tasks for Spark jobs
resource "google_dataplex_task" "spark_jobs" {
  for_each = { for job in var.spark_jobs : job.job_id => job }

  task_id      = each.value.job_id
  location     = var.location
  lake         = each.value.lake_id
  project      = var.project_id
  display_name = coalesce(each.value.display_name, each.value.job_id)
  description  = coalesce(each.value.description, "Spark job: ${each.value.job_id}")

  trigger_spec {
    type     = "ON_DEMAND"
  }

  execution_spec {
    service_account = google_service_account.spark_runner.email
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

    # Optional: Add infrastructure spec for serverless spark
    infrastructure_spec {
      batch {
        executors_count = 2
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
      service = "process"
      lake_id = each.value.lake_id
    }
  )

  depends_on = [data.google_dataplex_lake.lakes]
}

# Create service account for Spark job execution
resource "google_service_account" "spark_runner" {
  account_id   = "dataplex-spark-runner"
  display_name = "Dataplex Spark Runner"
  description  = "Service account for running Dataplex Spark jobs"
  project      = var.project_id
}

# Grant necessary permissions to Spark service account
resource "google_project_iam_member" "spark_runner_roles" {
  for_each = toset([
    "roles/dataplex.editor",
    "roles/bigquery.dataEditor",
    "roles/storage.objectAdmin",
    "roles/dataproc.worker"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.spark_runner.email}"
}

# Create GCS bucket for Spark job artifacts and logs
resource "google_storage_bucket" "spark_artifacts" {
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
      service = "process"
      purpose = "spark-artifacts"
    }
  )
}

# Grant Spark service account access to artifacts bucket
resource "google_storage_bucket_iam_member" "spark_artifacts_access" {
  bucket = google_storage_bucket.spark_artifacts.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.spark_runner.email}"
}

# Create BigQuery dataset for Spark job results
resource "google_bigquery_dataset" "spark_results" {
  dataset_id  = "dataplex_spark_results"
  project     = var.project_id
  location    = var.location
  description = "Dataset for Dataplex Spark job results and intermediate data"

  labels = merge(
    var.labels,
    {
      module  = "manage-lakes"
      service = "process"
      purpose = "spark-results"
    }
  )

  delete_contents_on_destroy = false
}

# Create a sample processing task (data quality checks)
resource "google_dataplex_task" "data_quality_check" {
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
    service_account = google_service_account.spark_runner.email
    max_job_execution_lifetime = "3600s"
  }

  spark {
    python_script_file = "gs://${google_storage_bucket.spark_artifacts.name}/scripts/data_quality_check.py"

    infrastructure_spec {
      batch {
        executors_count = 2
        max_executors_count = 3
      }
    }
  }

  labels = merge(
    var.labels,
    {
      module  = "manage-lakes"
      service = "process"
      type    = "quality-check"
    }
  )

  count = length(var.spark_jobs) > 0 ? 1 : 0

  depends_on = [data.google_dataplex_lake.lakes]
}

# Create a sample processing task (data profiling)
resource "google_dataplex_task" "data_profiling" {
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
    service_account = google_service_account.spark_runner.email
    max_job_execution_lifetime = "7200s"
  }

  spark {
    python_script_file = "gs://${google_storage_bucket.spark_artifacts.name}/scripts/data_profiling.py"

    infrastructure_spec {
      batch {
        executors_count = 3
        max_executors_count = 5
      }
    }
  }

  labels = merge(
    var.labels,
    {
      module  = "manage-lakes"
      service = "process"
      type    = "profiling"
    }
  )

  count = length(var.spark_jobs) > 0 ? 1 : 0

  depends_on = [data.google_dataplex_lake.lakes]
}

# Create notebook for interactive data analysis
resource "google_dataplex_task" "data_analysis_notebook" {
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
    service_account = google_service_account.spark_runner.email
  }

  notebook {
    notebook = "gs://${google_storage_bucket.spark_artifacts.name}/notebooks/analysis.ipynb"
    infrastructure_spec {
      batch {
        executors_count = 2
      }
    }
  }

  labels = merge(
    var.labels,
    {
      module  = "manage-lakes"
      service = "process"
      type    = "notebook"
    }
  )

  count = length(var.spark_jobs) > 0 ? 1 : 0

  depends_on = [data.google_dataplex_lake.lakes]
}

# Secure Service - IAM Bindings, Encryption, Access Policies

# Note: Lake IDs need to be passed from the manage module
# This is handled via dependencies in the parent module

# Data source to get existing lakes (assuming they exist from manage module)
data "google_dataplex_lake" "lakes" {
  for_each = toset([for binding in var.iam_bindings : binding.lake_id])

  lake     = each.value
  location = var.location
  project  = var.project_id
}

# IAM Bindings for Lakes
resource "google_dataplex_lake_iam_member" "bindings" {
  for_each = {
    for idx, binding in var.iam_bindings : "${binding.lake_id}-${binding.role}-${idx}" => binding
  }

  project  = var.project_id
  location = var.location
  lake     = each.value.lake_id
  role     = each.value.role
  member   = each.value.members[0] # Note: This handles one member per binding

  depends_on = [data.google_dataplex_lake.lakes]
}

# Create a service account for Dataplex operations
resource "google_service_account" "dataplex_sa" {
  account_id   = "dataplex-operations-sa"
  display_name = "Dataplex Operations Service Account"
  description  = "Service account for Dataplex data processing and governance operations"
  project      = var.project_id
}

# Grant necessary permissions to the service account
resource "google_project_iam_member" "dataplex_sa_roles" {
  for_each = toset([
    "roles/dataplex.admin",
    "roles/datacatalog.admin",
    "roles/bigquery.dataEditor",
    "roles/storage.objectAdmin"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.dataplex_sa.email}"
}

# Create KMS key ring for encryption
resource "google_kms_key_ring" "dataplex" {
  name     = "dataplex-keyring"
  location = var.location
  project  = var.project_id
}

# Create KMS crypto key for data encryption
resource "google_kms_crypto_key" "dataplex_data" {
  name            = "dataplex-data-key"
  key_ring        = google_kms_key_ring.dataplex.id
  rotation_period = "7776000s" # 90 days

  lifecycle {
    prevent_destroy = true
  }

  labels = merge(
    var.labels,
    {
      module  = "manage-lakes"
      service = "secure"
      purpose = "data-encryption"
    }
  )
}

# Grant KMS permissions to Dataplex service account
resource "google_kms_crypto_key_iam_member" "dataplex_sa_encrypter" {
  crypto_key_id = google_kms_crypto_key.dataplex_data.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_service_account.dataplex_sa.email}"
}

# Create VPC Service Controls access policy (optional)
# Note: This requires organization-level permissions
# Uncomment and configure if needed

# resource "google_access_context_manager_access_policy" "dataplex_policy" {
#   parent = "organizations/${var.organization_id}"
#   title  = "Dataplex Access Policy"
# }

# Create IAM Conditions for time-based access (example)
resource "google_dataplex_lake_iam_binding" "time_bound_access" {
  for_each = toset([for binding in var.iam_bindings : binding.lake_id])

  project  = var.project_id
  location = var.location
  lake     = each.value
  role     = "roles/dataplex.viewer"

  members = [
    "serviceAccount:${google_service_account.dataplex_sa.email}",
  ]

  condition {
    title       = "Business hours access"
    description = "Access allowed only during business hours (9am-5pm)"
    expression  = <<-EOT
      request.time.getHours("America/New_York") >= 9 &&
      request.time.getHours("America/New_York") <= 17
    EOT
  }

  depends_on = [data.google_dataplex_lake.lakes]
}

# Create audit logging configuration
resource "google_project_iam_audit_config" "dataplex_audit" {
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

# Create logging sink for security events
resource "google_logging_project_sink" "dataplex_security_sink" {
  name        = "dataplex-security-events"
  project     = var.project_id
  destination = "bigquery.googleapis.com/projects/${var.project_id}/datasets/${google_bigquery_dataset.security_logs.dataset_id}"

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

# Create BigQuery dataset for security logs
resource "google_bigquery_dataset" "security_logs" {
  dataset_id  = "dataplex_security_logs"
  project     = var.project_id
  location    = var.location
  description = "Security and audit logs for Dataplex operations"

  labels = merge(
    var.labels,
    {
      module  = "manage-lakes"
      service = "secure"
      purpose = "security-logs"
    }
  )

  default_table_expiration_ms = 7776000000 # 90 days
  delete_contents_on_destroy  = false
}

# Grant BigQuery data editor role to the log sink
resource "google_bigquery_dataset_iam_member" "sink_writer" {
  dataset_id = google_bigquery_dataset.security_logs.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = google_logging_project_sink.dataplex_security_sink.writer_identity
}

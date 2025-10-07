# Taxonomy Service - Policy Tags and Data Classification

# Create Data Catalog Taxonomy
resource "google_data_catalog_taxonomy" "main" {
  provider = google

  project      = var.project_id
  region       = var.location
  display_name = var.taxonomy_display_name
  description  = "Taxonomy for Dataplex data classification and governance"

  activated_policy_types = ["FINE_GRAINED_ACCESS_CONTROL"]
}

# Create Policy Tags dynamically
resource "google_data_catalog_policy_tag" "tags" {
  for_each = toset(var.policy_tags)

  taxonomy     = google_data_catalog_taxonomy.main.id
  display_name = each.value
  description  = "Policy tag for ${each.value}"
}

# Common policy tags for data classification
locals {
  default_policy_tags = [
    "Confidential",
    "Restricted",
    "Internal",
    "Public",
    "PII",
    "Sensitive"
  ]

  # Merge user-provided tags with defaults (user tags take precedence)
  all_tags = length(var.policy_tags) > 0 ? var.policy_tags : local.default_policy_tags
}

# Create hierarchical policy tags for data sensitivity
resource "google_data_catalog_policy_tag" "data_sensitivity" {
  taxonomy     = google_data_catalog_taxonomy.main.id
  display_name = "Data Sensitivity"
  description  = "Root tag for data sensitivity classification"
}

resource "google_data_catalog_policy_tag" "high_sensitivity" {
  taxonomy         = google_data_catalog_taxonomy.main.id
  display_name     = "High Sensitivity"
  description      = "Highly sensitive data requiring strict access controls"
  parent_policy_tag = google_data_catalog_policy_tag.data_sensitivity.id
}

resource "google_data_catalog_policy_tag" "medium_sensitivity" {
  taxonomy         = google_data_catalog_taxonomy.main.id
  display_name     = "Medium Sensitivity"
  description      = "Moderately sensitive data with controlled access"
  parent_policy_tag = google_data_catalog_policy_tag.data_sensitivity.id
}

resource "google_data_catalog_policy_tag" "low_sensitivity" {
  taxonomy         = google_data_catalog_taxonomy.main.id
  display_name     = "Low Sensitivity"
  description      = "Low sensitivity data with minimal access restrictions"
  parent_policy_tag = google_data_catalog_policy_tag.data_sensitivity.id
}

# Create IAM policy for taxonomy
resource "google_data_catalog_taxonomy_iam_member" "fine_grained_reader" {
  taxonomy = google_data_catalog_taxonomy.main.id
  role     = "roles/datacatalog.categoryFineGrainedReader"
  member   = "projectEditor:${var.project_id}"
}

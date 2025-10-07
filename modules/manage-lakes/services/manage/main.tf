# Manage Service - Lakes, Zones, and Assets

# Create Dataplex Lakes
resource "google_dataplex_lake" "lakes" {
  for_each = { for lake in var.lakes : lake.lake_id => lake }

  lake_id      = each.value.lake_id
  location     = var.location
  project      = var.project_id
  display_name = coalesce(each.value.display_name, each.value.lake_id)
  description  = coalesce(each.value.description, "Dataplex lake: ${each.value.lake_id}")

  labels = merge(
    var.labels,
    each.value.labels,
    {
      module  = "manage-lakes"
      service = "manage"
    }
  )
}

# Create Dataplex Zones
locals {
  # Flatten zones from all lakes
  zones = flatten([
    for lake in var.lakes : [
      for zone in coalesce(lake.zones, []) : {
        zone_id       = zone.zone_id
        lake_id       = lake.lake_id
        type          = zone.type
        display_name  = zone.display_name
        description   = zone.description
        location_type = zone.location_type
      }
    ]
  ])

  zones_map = {
    for zone in local.zones : "${zone.lake_id}-${zone.zone_id}" => zone
  }
}

resource "google_dataplex_zone" "zones" {
  for_each = local.zones_map

  lake         = google_dataplex_lake.lakes[each.value.lake_id].id
  location     = var.location
  zone_id      = each.value.zone_id
  type         = each.value.type
  display_name = coalesce(each.value.display_name, each.value.zone_id)
  description  = coalesce(each.value.description, "${each.value.type} zone: ${each.value.zone_id}")

  resource_spec {
    location_type = each.value.location_type
  }

  discovery_spec {
    enabled = true
    schedule = "0 * * * *" # Hourly discovery
  }

  labels = merge(
    var.labels,
    {
      module  = "manage-lakes"
      service = "manage"
      lake_id = each.value.lake_id
    }
  )
}

# Example: Create a GCS bucket for RAW zone
resource "google_storage_bucket" "raw_zone_bucket" {
  for_each = {
    for k, v in local.zones_map : k => v
    if v.type == "RAW"
  }

  name     = "${var.project_id}-${each.value.lake_id}-${each.value.zone_id}"
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
      module  = "manage-lakes"
      service = "manage"
      zone_type = "raw"
      lake_id = each.value.lake_id
    }
  )
}

# Example: Create a BigQuery dataset for CURATED zone
resource "google_bigquery_dataset" "curated_zone_dataset" {
  for_each = {
    for k, v in local.zones_map : k => v
    if v.type == "CURATED"
  }

  dataset_id  = replace("${each.value.lake_id}_${each.value.zone_id}", "-", "_")
  project     = var.project_id
  location    = var.location
  description = "Curated zone dataset for ${each.value.lake_id}"

  labels = merge(
    var.labels,
    {
      module    = "manage-lakes"
      service   = "manage"
      zone_type = "curated"
      lake_id   = each.value.lake_id
    }
  )

  delete_contents_on_destroy = false
}

# Create Dataplex Assets for GCS buckets (RAW zones)
resource "google_dataplex_asset" "raw_assets" {
  for_each = google_storage_bucket.raw_zone_bucket

  asset_id     = "${each.value.name}-asset"
  lake         = google_dataplex_lake.lakes[local.zones_map[each.key].lake_id].id
  location     = var.location
  dataplex_zone = google_dataplex_zone.zones[each.key].id
  display_name = "${each.value.name} Asset"
  description  = "Asset for RAW zone bucket ${each.value.name}"

  resource_spec {
    name = "projects/${var.project_id}/buckets/${each.value.name}"
    type = "STORAGE_BUCKET"
  }

  discovery_spec {
    enabled = true
    schedule = "0 * * * *" # Hourly discovery
  }

  labels = merge(
    var.labels,
    {
      module  = "manage-lakes"
      service = "manage"
      asset_type = "gcs-bucket"
    }
  )
}

# Create Dataplex Assets for BigQuery datasets (CURATED zones)
resource "google_dataplex_asset" "curated_assets" {
  for_each = google_bigquery_dataset.curated_zone_dataset

  asset_id      = "${each.value.dataset_id}-asset"
  lake          = google_dataplex_lake.lakes[local.zones_map[each.key].lake_id].id
  location      = var.location
  dataplex_zone = google_dataplex_zone.zones[each.key].id
  display_name  = "${each.value.dataset_id} Asset"
  description   = "Asset for CURATED zone dataset ${each.value.dataset_id}"

  resource_spec {
    name = "projects/${var.project_id}/datasets/${each.value.dataset_id}"
    type = "BIGQUERY_DATASET"
  }

  discovery_spec {
    enabled = true
    schedule = "0 * * * *" # Hourly discovery
  }

  labels = merge(
    var.labels,
    {
      module     = "manage-lakes"
      service    = "manage"
      asset_type = "bigquery-dataset"
    }
  )
}

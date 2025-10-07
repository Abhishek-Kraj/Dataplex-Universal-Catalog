# Catalog Service - Entry Groups, Entry Types, and Aspect Types

# Create Dataplex Entry Groups
resource "google_dataplex_entry_group" "groups" {
  for_each = { for eg in var.entry_groups : eg.entry_group_id => eg }

  entry_group_id = each.value.entry_group_id
  project        = var.project_id
  location       = var.location

  display_name = coalesce(each.value.display_name, each.value.entry_group_id)
  description  = coalesce(each.value.description, "Entry group for ${each.value.entry_group_id}")

  labels = merge(
    var.labels,
    {
      module  = "manage-metadata"
      service = "catalog"
    }
  )
}

# Create Dataplex Entry Type for Data Assets
resource "google_dataplex_entry_type" "data_asset" {
  entry_type_id = "data-asset-entry-type"
  project       = var.project_id
  location      = var.location

  display_name = "Data Asset Entry Type"
  description  = "Entry type for data assets in Dataplex"

  required_aspects {
    type = "dataplex.googleapis.com/Schema"
  }

  labels = merge(
    var.labels,
    {
      module  = "manage-metadata"
      service = "catalog"
      type    = "entry-type"
    }
  )
}

# Create Dataplex Entry Type for Tables
resource "google_dataplex_entry_type" "table" {
  entry_type_id = "table-entry-type"
  project       = var.project_id
  location      = var.location

  display_name = "Table Entry Type"
  description  = "Entry type for tables in Dataplex"

  required_aspects {
    type = "dataplex.googleapis.com/Schema"
  }

  labels = merge(
    var.labels,
    {
      module  = "manage-metadata"
      service = "catalog"
      type    = "entry-type"
    }
  )
}

# Create Dataplex Aspect Type for Data Quality
resource "google_dataplex_aspect_type" "data_quality" {
  aspect_type_id = "data-quality-aspect"
  project        = var.project_id
  location       = var.location

  display_name = "Data Quality Aspect"
  description  = "Aspect type for data quality metrics"

  metadata_template = jsonencode({
    type = "record"
    name = "DataQuality"
    fields = [
      {
        name = "quality_score"
        type = "double"
      },
      {
        name = "completeness"
        type = "double"
      },
      {
        name = "accuracy"
        type = "double"
      },
      {
        name = "consistency"
        type = "double"
      },
      {
        name = "last_assessed"
        type = "string"
      }
    ]
  })

  labels = merge(
    var.labels,
    {
      module  = "manage-metadata"
      service = "catalog"
      type    = "aspect-type"
    }
  )
}

# Create Dataplex Aspect Type for Business Metadata
resource "google_dataplex_aspect_type" "business_metadata" {
  aspect_type_id = "business-metadata-aspect"
  project        = var.project_id
  location       = var.location

  display_name = "Business Metadata Aspect"
  description  = "Aspect type for business metadata"

  metadata_template = jsonencode({
    type = "record"
    name = "BusinessMetadata"
    fields = [
      {
        name = "owner"
        type = "string"
      },
      {
        name = "domain"
        type = "string"
      },
      {
        name = "steward"
        type = "string"
      },
      {
        name = "business_definition"
        type = "string"
      },
      {
        name = "tags"
        type = {
          type  = "array"
          items = "string"
        }
      }
    ]
  })

  labels = merge(
    var.labels,
    {
      module  = "manage-metadata"
      service = "catalog"
      type    = "aspect-type"
    }
  )
}

# Create Dataplex Aspect Type for Lineage
resource "google_dataplex_aspect_type" "lineage" {
  aspect_type_id = "lineage-aspect"
  project        = var.project_id
  location       = var.location

  display_name = "Lineage Aspect"
  description  = "Aspect type for data lineage tracking"

  metadata_template = jsonencode({
    type = "record"
    name = "Lineage"
    fields = [
      {
        name = "upstream_sources"
        type = {
          type  = "array"
          items = "string"
        }
      },
      {
        name = "downstream_targets"
        type = {
          type  = "array"
          items = "string"
        }
      },
      {
        name = "transformation_logic"
        type = "string"
      },
      {
        name = "last_updated"
        type = "string"
      }
    ]
  })

  labels = merge(
    var.labels,
    {
      module  = "manage-metadata"
      service = "catalog"
      type    = "aspect-type"
    }
  )
}

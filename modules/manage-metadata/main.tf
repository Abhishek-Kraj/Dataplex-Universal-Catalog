# ==============================================================================
# DATAPLEX MANAGE METADATA MODULE
# ==============================================================================
# This module manages entry groups, entry types, aspect types, and glossaries
# All resources are controlled via variables - use enable_* flags to toggle features
# ==============================================================================

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
    recordFields = [
      {
        name  = "quality_score"
        type  = "double"
        index = 1
        annotations = {
          description = "Overall quality score (0-1)"
        }
      },
      {
        name  = "completeness"
        type  = "double"
        index = 2
        annotations = {
          description = "Data completeness score (0-1)"
        }
      },
      {
        name  = "accuracy"
        type  = "double"
        index = 3
        annotations = {
          description = "Data accuracy score (0-1)"
        }
      },
      {
        name  = "consistency"
        type  = "double"
        index = 4
        annotations = {
          description = "Data consistency score (0-1)"
        }
      },
      {
        name  = "last_assessed"
        type  = "string"
        index = 5
        annotations = {
          description = "Timestamp of last quality assessment"
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
    recordFields = [
      {
        name  = "owner"
        type  = "string"
        index = 1
        annotations = {
          description = "Data owner"
        }
      },
      {
        name  = "domain"
        type  = "string"
        index = 2
        annotations = {
          description = "Business domain"
        }
      },
      {
        name  = "steward"
        type  = "string"
        index = 3
        annotations = {
          description = "Data steward"
        }
      },
      {
        name  = "business_definition"
        type  = "string"
        index = 4
        annotations = {
          description = "Business definition"
        }
      },
      {
        name  = "tags"
        type  = "string"
        index = 5
        annotations = {
          description = "Comma-separated tags"
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
    recordFields = [
      {
        name  = "upstream_sources"
        type  = "string"
        index = 1
        annotations = {
          description = "Comma-separated upstream source identifiers"
        }
      },
      {
        name  = "downstream_targets"
        type  = "string"
        index = 2
        annotations = {
          description = "Comma-separated downstream target identifiers"
        }
      },
      {
        name  = "transformation_logic"
        type  = "string"
        index = 3
        annotations = {
          description = "Transformation logic description"
        }
      },
      {
        name  = "last_updated"
        type  = "string"
        index = 4
        annotations = {
          description = "Last update timestamp"
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
# Glossaries Service - Business Glossaries and Terms

# Note: As of now, Dataplex doesn't have native glossary resources
# We'll use Data Catalog for glossary management

# Create a dedicated entry group for glossary terms
resource "google_dataplex_entry_group" "glossary_group" {
  entry_group_id = "business-glossary-group"
  project        = var.project_id
  location       = var.location

  display_name = "Business Glossary Entry Group"
  description  = "Entry group for business glossary terms"

  labels = merge(
    var.labels,
    {
      module  = "manage-metadata"
      service = "glossaries"
    }
  )
}

# Create a custom aspect type for glossary terms
resource "google_dataplex_aspect_type" "glossary_term" {
  aspect_type_id = "glossary-term-aspect"
  project        = var.project_id
  location       = var.location

  display_name = "Glossary Term Aspect"
  description  = "Aspect type for business glossary terms"

  metadata_template = jsonencode({
    type = "record"
    name = "GlossaryTerm"
    recordFields = [
      {
        name  = "term_name"
        type  = "string"
        index = 1
        annotations = {
          description = "Term name"
        }
      },
      {
        name  = "definition"
        type  = "string"
        index = 2
        annotations = {
          description = "Term definition"
        }
      },
      {
        name  = "synonyms"
        type  = "string"
        index = 3
        annotations = {
          description = "Comma-separated synonyms"
        }
      },
      {
        name  = "related_terms"
        type  = "string"
        index = 4
        annotations = {
          description = "Comma-separated related terms"
        }
      },
      {
        name  = "owner"
        type  = "string"
        index = 5
        annotations = {
          description = "Term owner"
        }
      },
      {
        name  = "status"
        type  = "string"
        index = 6
        annotations = {
          description = "Term status"
        }
      },
      {
        name  = "domain"
        type  = "string"
        index = 7
        annotations = {
          description = "Business domain"
        }
      },
      {
        name  = "examples"
        type  = "string"
        index = 8
        annotations = {
          description = "Comma-separated examples"
        }
      }
    ]
  })

  labels = merge(
    var.labels,
    {
      module  = "manage-metadata"
      service = "glossaries"
    }
  )
}

# Create BigQuery dataset for storing glossary data
resource "google_bigquery_dataset" "glossary" {
  dataset_id  = "business_glossary"
  project     = var.project_id
  location    = var.location
  description = "Dataset for business glossary and terms"

  labels = merge(
    var.labels,
    {
      module  = "manage-metadata"
      service = "glossaries"
    }
  )

  delete_contents_on_destroy = false
}

# Create glossary terms table
resource "google_bigquery_table" "glossary_terms" {
  dataset_id          = google_bigquery_dataset.glossary.dataset_id
  table_id            = "glossary_terms"
  project             = var.project_id
  deletion_protection = false

  schema = jsonencode([
    {
      name = "term_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "glossary_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "term_name"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "display_name"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "definition"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "synonyms"
      type = "STRING"
      mode = "REPEATED"
    },
    {
      name = "related_terms"
      type = "STRING"
      mode = "REPEATED"
    },
    {
      name = "owner"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "status"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "domain"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "created_at"
      type = "TIMESTAMP"
      mode = "NULLABLE"
    },
    {
      name = "updated_at"
      type = "TIMESTAMP"
      mode = "NULLABLE"
    }
  ])

  labels = merge(
    var.labels,
    {
      module  = "manage-metadata"
      service = "glossaries"
    }
  )
}

# Create glossary metadata table
resource "google_bigquery_table" "glossaries" {
  dataset_id          = google_bigquery_dataset.glossary.dataset_id
  table_id            = "glossaries"
  project             = var.project_id
  deletion_protection = false

  schema = jsonencode([
    {
      name = "glossary_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "display_name"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "description"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "owner"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "domain"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "term_count"
      type = "INTEGER"
      mode = "NULLABLE"
    },
    {
      name = "created_at"
      type = "TIMESTAMP"
      mode = "NULLABLE"
    },
    {
      name = "updated_at"
      type = "TIMESTAMP"
      mode = "NULLABLE"
    }
  ])

  labels = merge(
    var.labels,
    {
      module  = "manage-metadata"
      service = "glossaries"
    }
  )
}

# Create term relationships table
resource "google_bigquery_table" "term_relationships" {
  dataset_id          = google_bigquery_dataset.glossary.dataset_id
  table_id            = "term_relationships"
  project             = var.project_id
  deletion_protection = false

  schema = jsonencode([
    {
      name = "relationship_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "source_term_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "target_term_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "relationship_type"
      type = "STRING"
      mode = "REQUIRED"
      description = "Types: SYNONYM, RELATED, PARENT, CHILD, REPLACES, REPLACED_BY"
    },
    {
      name = "created_at"
      type = "TIMESTAMP"
      mode = "NULLABLE"
    }
  ])

  labels = merge(
    var.labels,
    {
      module  = "manage-metadata"
      service = "glossaries"
    }
  )
}

# Create view for term hierarchy
resource "google_bigquery_table" "term_hierarchy_view" {
  dataset_id          = google_bigquery_dataset.glossary.dataset_id
  table_id            = "term_hierarchy_view"
  project             = var.project_id
  deletion_protection = false

  view {
    query = <<-SQL
      WITH RECURSIVE term_hierarchy AS (
        SELECT
          t.term_id,
          t.term_name,
          t.glossary_id,
          t.definition,
          0 as level,
          CAST(t.term_id AS STRING) as path
        FROM `${var.project_id}.${google_bigquery_dataset.glossary.dataset_id}.glossary_terms` t
        WHERE NOT EXISTS (
          SELECT 1 FROM `${var.project_id}.${google_bigquery_dataset.glossary.dataset_id}.term_relationships` r
          WHERE r.target_term_id = t.term_id AND r.relationship_type = 'PARENT'
        )

        UNION ALL

        SELECT
          t.term_id,
          t.term_name,
          t.glossary_id,
          t.definition,
          th.level + 1,
          CONCAT(th.path, ' > ', t.term_id)
        FROM `${var.project_id}.${google_bigquery_dataset.glossary.dataset_id}.glossary_terms` t
        JOIN `${var.project_id}.${google_bigquery_dataset.glossary.dataset_id}.term_relationships` r
          ON r.target_term_id = t.term_id
        JOIN term_hierarchy th
          ON r.source_term_id = th.term_id
        WHERE r.relationship_type = 'PARENT' AND th.level < 10
      )
      SELECT * FROM term_hierarchy
    SQL

    use_legacy_sql = false
  }

  labels = merge(
    var.labels,
    {
      module  = "manage-metadata"
      service = "glossaries"
    }
  )
}

# Initialize glossary data if provided
locals {
  glossary_init_data = [
    for g in var.glossaries : {
      glossary_id  = g.glossary_id
      display_name = coalesce(g.display_name, g.glossary_id)
      description  = coalesce(g.description, "Business glossary for ${g.glossary_id}")
      term_count   = length(coalesce(g.terms, []))
    }
  ]
}

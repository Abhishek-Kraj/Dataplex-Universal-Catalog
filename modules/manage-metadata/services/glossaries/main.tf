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
    fields = [
      {
        name = "term_name"
        type = "string"
      },
      {
        name = "definition"
        type = "string"
      },
      {
        name = "synonyms"
        type = {
          type  = "array"
          items = "string"
        }
      },
      {
        name = "related_terms"
        type = {
          type  = "array"
          items = "string"
        }
      },
      {
        name = "owner"
        type = "string"
      },
      {
        name = "status"
        type = "string"
      },
      {
        name = "domain"
        type = "string"
      },
      {
        name = "examples"
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

output "entry_groups" {
  description = "Map of entry group IDs to their details"
  value       = google_dataplex_entry_group.groups
}

output "entry_types" {
  description = "Map of entry type IDs to their details"
  value = {
    data_asset = google_dataplex_entry_type.data_asset
    table      = google_dataplex_entry_type.table
  }
}

output "aspect_types" {
  description = "Map of aspect type IDs to their details"
  value = {
    data_quality      = google_dataplex_aspect_type.data_quality
    business_metadata = google_dataplex_aspect_type.business_metadata
    lineage           = google_dataplex_aspect_type.lineage
    glossary_term     = var.enable_glossaries ? google_dataplex_aspect_type.glossary_term : null
  }
}

output "glossary_dataset" {
  description = "BigQuery dataset for glossaries"
  value       = var.enable_glossaries ? google_bigquery_dataset.glossary : null
}

output "glossary_tables" {
  description = "BigQuery tables for glossary data"
  value = var.enable_glossaries ? {
    terms         = google_bigquery_table.glossary_terms
    glossaries    = google_bigquery_table.glossaries
    relationships = google_bigquery_table.term_relationships
  } : {}
}

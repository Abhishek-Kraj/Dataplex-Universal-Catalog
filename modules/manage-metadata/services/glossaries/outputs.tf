output "glossaries" {
  description = "Glossary configuration details"
  value = {
    dataset_id     = google_bigquery_dataset.glossary.dataset_id
    entry_group_id = google_dataplex_entry_group.glossary_group.id
    aspect_type_id = google_dataplex_aspect_type.glossary_term.id
  }
}

output "glossary_terms" {
  description = "Glossary terms table details"
  value = {
    terms_table_id         = google_bigquery_table.glossary_terms.table_id
    glossaries_table_id    = google_bigquery_table.glossaries.table_id
    relationships_table_id = google_bigquery_table.term_relationships.table_id
    hierarchy_view_id      = google_bigquery_table.term_hierarchy_view.table_id
  }
}

output "glossary_dataset_id" {
  description = "BigQuery dataset ID for glossary"
  value       = google_bigquery_dataset.glossary.dataset_id
}

output "glossary_entry_group_id" {
  description = "Entry group ID for glossary"
  value       = google_dataplex_entry_group.glossary_group.id
}

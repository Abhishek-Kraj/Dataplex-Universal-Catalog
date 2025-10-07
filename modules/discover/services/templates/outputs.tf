output "templates" {
  description = "Map of metadata template IDs"
  value = {
    data_asset      = google_data_catalog_tag_template.data_asset.id
    table_metadata  = google_data_catalog_tag_template.table_metadata.id
    column_metadata = google_data_catalog_tag_template.column_metadata.id
  }
}

output "data_asset_template_id" {
  description = "Data asset template ID"
  value       = google_data_catalog_tag_template.data_asset.id
}

output "table_metadata_template_id" {
  description = "Table metadata template ID"
  value       = google_data_catalog_tag_template.table_metadata.id
}

output "column_metadata_template_id" {
  description = "Column metadata template ID"
  value       = google_data_catalog_tag_template.column_metadata.id
}

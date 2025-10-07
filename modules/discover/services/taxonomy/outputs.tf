output "taxonomy_id" {
  description = "The ID of the created taxonomy"
  value       = google_data_catalog_taxonomy.main.id
}

output "taxonomy_name" {
  description = "The name of the created taxonomy"
  value       = google_data_catalog_taxonomy.main.name
}

output "policy_tags" {
  description = "Map of policy tag display names to their IDs"
  value = merge(
    { for k, v in google_data_catalog_policy_tag.tags : v.display_name => v.id },
    {
      "Data Sensitivity"  = google_data_catalog_policy_tag.data_sensitivity.id
      "High Sensitivity"  = google_data_catalog_policy_tag.high_sensitivity.id
      "Medium Sensitivity" = google_data_catalog_policy_tag.medium_sensitivity.id
      "Low Sensitivity"   = google_data_catalog_policy_tag.low_sensitivity.id
    }
  )
}

output "policy_tag_ids" {
  description = "List of all policy tag IDs"
  value = concat(
    [for tag in google_data_catalog_policy_tag.tags : tag.id],
    [
      google_data_catalog_policy_tag.data_sensitivity.id,
      google_data_catalog_policy_tag.high_sensitivity.id,
      google_data_catalog_policy_tag.medium_sensitivity.id,
      google_data_catalog_policy_tag.low_sensitivity.id
    ]
  )
}

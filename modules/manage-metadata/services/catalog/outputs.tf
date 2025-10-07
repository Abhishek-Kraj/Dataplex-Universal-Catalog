output "entry_groups" {
  description = "Map of entry group IDs to their details"
  value = {
    for k, v in google_dataplex_entry_group.groups : k => {
      id           = v.id
      name         = v.name
      display_name = v.display_name
      uid          = v.uid
    }
  }
}

output "entry_types" {
  description = "Map of entry type IDs"
  value = {
    data_asset = google_dataplex_entry_type.data_asset.id
    table      = google_dataplex_entry_type.table.id
  }
}

output "aspect_types" {
  description = "Map of aspect type IDs"
  value = {
    data_quality      = google_dataplex_aspect_type.data_quality.id
    business_metadata = google_dataplex_aspect_type.business_metadata.id
    lineage           = google_dataplex_aspect_type.lineage.id
  }
}

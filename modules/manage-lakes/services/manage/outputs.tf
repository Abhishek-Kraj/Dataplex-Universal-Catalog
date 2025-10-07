output "lakes" {
  description = "Map of lake IDs to their details"
  value = {
    for k, v in google_dataplex_lake.lakes : k => {
      id           = v.id
      name         = v.name
      uid          = v.uid
      display_name = v.display_name
      state        = v.state
    }
  }
}

output "zones" {
  description = "Map of zone IDs to their details"
  value = {
    for k, v in google_dataplex_zone.zones : k => {
      id           = v.id
      name         = v.name
      uid          = v.uid
      display_name = v.display_name
      type         = v.type
      state        = v.state
    }
  }
}

output "assets" {
  description = "Map of asset IDs to their details"
  value = merge(
    {
      for k, v in google_dataplex_asset.raw_assets : k => {
        id           = v.id
        name         = v.name
        uid          = v.uid
        display_name = v.display_name
        state        = v.state
        type         = "RAW"
      }
    },
    {
      for k, v in google_dataplex_asset.curated_assets : k => {
        id           = v.id
        name         = v.name
        uid          = v.uid
        display_name = v.display_name
        state        = v.state
        type         = "CURATED"
      }
    }
  )
}

output "raw_buckets" {
  description = "Map of RAW zone bucket names"
  value = {
    for k, v in google_storage_bucket.raw_zone_bucket : k => v.name
  }
}

output "curated_datasets" {
  description = "Map of CURATED zone dataset IDs"
  value = {
    for k, v in google_bigquery_dataset.curated_zone_dataset : k => v.dataset_id
  }
}

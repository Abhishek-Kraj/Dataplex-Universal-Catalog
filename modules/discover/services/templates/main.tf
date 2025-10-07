# Templates Service - Metadata Templates for Data Catalog

# Create tag template for data asset metadata
resource "google_data_catalog_tag_template" "data_asset" {
  tag_template_id = "dataplex_data_asset_template"
  project         = var.project_id
  region          = var.location
  display_name    = "Dataplex Data Asset Template"

  fields {
    field_id     = "owner"
    display_name = "Data Owner"
    description  = "Owner of the data asset"
    type {
      primitive_type = "STRING"
    }
    is_required = true
  }

  fields {
    field_id     = "data_domain"
    display_name = "Data Domain"
    description  = "Business domain of the data"
    type {
      primitive_type = "STRING"
    }
    is_required = false
  }

  fields {
    field_id     = "data_quality_score"
    display_name = "Data Quality Score"
    description  = "Quality score of the data (0-100)"
    type {
      primitive_type = "DOUBLE"
    }
    is_required = false
  }

  fields {
    field_id     = "refresh_frequency"
    display_name = "Refresh Frequency"
    description  = "How often the data is refreshed"
    type {
      enum_type {
        allowed_values {
          display_name = "Real-time"
        }
        allowed_values {
          display_name = "Daily"
        }
        allowed_values {
          display_name = "Weekly"
        }
        allowed_values {
          display_name = "Monthly"
        }
      }
    }
    is_required = false
  }

  fields {
    field_id     = "retention_period"
    display_name = "Retention Period"
    description  = "Data retention period in days"
    type {
      primitive_type = "DOUBLE"
    }
    is_required = false
  }

  fields {
    field_id     = "compliance_tags"
    display_name = "Compliance Tags"
    description  = "Compliance and regulatory tags (e.g., GDPR, HIPAA)"
    type {
      primitive_type = "STRING"
    }
    is_required = false
  }

  force_delete = false
}

# Create tag template for table-level metadata
resource "google_data_catalog_tag_template" "table_metadata" {
  tag_template_id = "dataplex_table_metadata_template"
  project         = var.project_id
  region          = var.location
  display_name    = "Dataplex Table Metadata Template"

  fields {
    field_id     = "table_type"
    display_name = "Table Type"
    description  = "Type of the table"
    type {
      enum_type {
        allowed_values {
          display_name = "Fact"
        }
        allowed_values {
          display_name = "Dimension"
        }
        allowed_values {
          display_name = "Aggregate"
        }
        allowed_values {
          display_name = "Staging"
        }
      }
    }
    is_required = false
  }

  fields {
    field_id     = "business_definition"
    display_name = "Business Definition"
    description  = "Business definition of the table"
    type {
      primitive_type = "STRING"
    }
    is_required = false
  }

  fields {
    field_id     = "record_count"
    display_name = "Record Count"
    description  = "Approximate number of records"
    type {
      primitive_type = "DOUBLE"
    }
    is_required = false
  }

  fields {
    field_id     = "last_updated"
    display_name = "Last Updated"
    description  = "Last update timestamp"
    type {
      primitive_type = "TIMESTAMP"
    }
    is_required = false
  }

  force_delete = false
}

# Create tag template for column-level metadata
resource "google_data_catalog_tag_template" "column_metadata" {
  tag_template_id = "dataplex_column_metadata_template"
  project         = var.project_id
  region          = var.location
  display_name    = "Dataplex Column Metadata Template"

  fields {
    field_id     = "is_pii"
    display_name = "Contains PII"
    description  = "Whether the column contains personally identifiable information"
    type {
      primitive_type = "BOOL"
    }
    is_required = false
  }

  fields {
    field_id     = "data_classification"
    display_name = "Data Classification"
    description  = "Classification level of the data"
    type {
      enum_type {
        allowed_values {
          display_name = "Public"
        }
        allowed_values {
          display_name = "Internal"
        }
        allowed_values {
          display_name = "Confidential"
        }
        allowed_values {
          display_name = "Restricted"
        }
      }
    }
    is_required = false
  }

  fields {
    field_id     = "business_name"
    display_name = "Business Name"
    description  = "Business-friendly name for the column"
    type {
      primitive_type = "STRING"
    }
    is_required = false
  }

  fields {
    field_id     = "masking_required"
    display_name = "Masking Required"
    description  = "Whether data masking is required"
    type {
      primitive_type = "BOOL"
    }
    is_required = false
  }

  force_delete = false
}

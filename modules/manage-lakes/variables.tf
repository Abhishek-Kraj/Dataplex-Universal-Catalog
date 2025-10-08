variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
}

variable "location" {
  description = "The GCP location"
  type        = string
}

variable "enable_manage" {
  description = "Enable lake management"
  type        = bool
  default     = true
}

variable "enable_secure" {
  description = "Enable security features"
  type        = bool
  default     = true
}

variable "enable_process" {
  description = "Enable data processing"
  type        = bool
  default     = true
}

variable "lakes" {
  description = "List of lakes to create"
  type = list(object({
    lake_id      = string
    display_name = optional(string)
    description  = optional(string)
    labels       = optional(map(string), {})
    zones = optional(list(object({
      zone_id       = string
      type          = string
      display_name  = optional(string)
      description   = optional(string)
      location_type = optional(string, "SINGLE_REGION")
      # Support for existing resources
      existing_bucket  = optional(string)  # For RAW zones - existing GCS bucket name
      existing_dataset = optional(string)  # For CURATED zones - existing BQ dataset ID
      create_storage   = optional(bool, true)  # Set to false to skip bucket/dataset creation

      # Custom names for new resources (only used when create_storage = true)
      bucket_name  = optional(string)  # Custom GCS bucket name (default: auto-generated)
      dataset_id   = optional(string)  # Custom BigQuery dataset ID (default: auto-generated)
    })), [])
  }))
  default = []
}

variable "iam_bindings" {
  description = "List of IAM bindings"
  type = list(object({
    lake_id = string
    role    = string
    members = list(string)
  }))
  default = []
}

variable "spark_jobs" {
  description = "List of Spark jobs to create"
  type = list(object({
    job_id       = string
    lake_id      = string
    display_name = optional(string)
    description  = optional(string)
    main_class   = optional(string)
    main_jar_uri = optional(string)
    args         = optional(list(string), [])
  }))
  default = []
}

variable "spark_sql_jobs" {
  description = "List of Spark SQL jobs to create"
  type = list(object({
    job_id        = string
    lake_id       = string
    display_name  = optional(string)
    description   = optional(string)
    sql_script    = optional(string)        # Inline SQL script
    sql_file_uri  = optional(string)        # GCS path to SQL file
    file_uris     = optional(list(string))  # Additional files
    archive_uris  = optional(list(string))  # JAR/ZIP dependencies
    schedule      = optional(string)        # Cron schedule
  }))
  default = []
}

variable "notebook_jobs" {
  description = "List of Jupyter notebook jobs to create"
  type = list(object({
    job_id          = string
    lake_id         = string
    display_name    = optional(string)
    description     = optional(string)
    notebook_uri    = string                 # GCS path to .ipynb file
    file_uris       = optional(list(string)) # Python/data files
    archive_uris    = optional(list(string)) # ZIP/TAR dependencies
    container_image = optional(string)       # Custom container image
    schedule        = optional(string)       # Cron schedule
  }))
  default = []
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}

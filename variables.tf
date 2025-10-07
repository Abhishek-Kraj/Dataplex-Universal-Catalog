variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for Dataplex resources"
  type        = string
  default     = "us-central1"
}

variable "location" {
  description = "The GCP location for Dataplex resources"
  type        = string
  default     = "us-central1"
}

# Feature toggles
variable "enable_discover" {
  description = "Enable Discover module (search, taxonomy, templates)"
  type        = bool
  default     = true
}

variable "enable_manage_metadata" {
  description = "Enable Manage Metadata module (catalog, glossaries)"
  type        = bool
  default     = true
}

variable "enable_manage_lakes" {
  description = "Enable Manage Lakes module (lakes, zones, assets)"
  type        = bool
  default     = true
}

variable "enable_govern" {
  description = "Enable Govern module (profiling, quality, monitoring)"
  type        = bool
  default     = true
}

# Discover Module Variables
variable "discover_config" {
  description = "Configuration for Discover module"
  type = object({
    enable_search          = optional(bool, true)
    enable_taxonomy        = optional(bool, true)
    enable_templates       = optional(bool, true)
    search_scope           = optional(string, "PROJECT")
    search_result_limit    = optional(number, 100)
    taxonomy_display_name  = optional(string, "Dataplex Taxonomy")
    policy_tags            = optional(list(string), [])
  })
  default = {}
}

# Manage Metadata Module Variables
variable "manage_metadata_config" {
  description = "Configuration for Manage Metadata module"
  type = object({
    enable_catalog    = optional(bool, true)
    enable_glossaries = optional(bool, true)
    entry_groups = optional(list(object({
      entry_group_id = string
      display_name   = optional(string)
      description    = optional(string)
    })), [])
    glossaries = optional(list(object({
      glossary_id  = string
      display_name = optional(string)
      description  = optional(string)
      terms = optional(list(object({
        term_id      = string
        display_name = optional(string)
        description  = optional(string)
      })), [])
    })), [])
  })
  default = {}
}

# Manage Lakes Module Variables
variable "manage_lakes_config" {
  description = "Configuration for Manage Lakes module"
  type = object({
    enable_manage  = optional(bool, true)
    enable_secure  = optional(bool, true)
    enable_process = optional(bool, true)
    lakes = optional(list(object({
      lake_id      = string
      display_name = optional(string)
      description  = optional(string)
      labels       = optional(map(string), {})
      zones = optional(list(object({
        zone_id      = string
        type         = string
        display_name = optional(string)
        description  = optional(string)
        location_type = optional(string, "SINGLE_REGION")
      })), [])
    })), [])
    iam_bindings = optional(list(object({
      lake_id = string
      role    = string
      members = list(string)
    })), [])
    spark_jobs = optional(list(object({
      job_id       = string
      lake_id      = string
      display_name = optional(string)
      description  = optional(string)
      main_class   = optional(string)
      main_jar_uri = optional(string)
      args         = optional(list(string), [])
    })), [])
  })
  default = {}
}

# Govern Module Variables
variable "govern_config" {
  description = "Configuration for Govern module"
  type = object({
    enable_profiling   = optional(bool, true)
    enable_quality     = optional(bool, true)
    enable_monitoring  = optional(bool, true)
    quality_scans = optional(list(object({
      scan_id      = string
      lake_id      = string
      display_name = optional(string)
      description  = optional(string)
      data_source  = string
      rules = optional(list(object({
        rule_type   = string
        column      = optional(string)
        threshold   = optional(number, 0.95)
        dimension   = optional(string, "COMPLETENESS")
      })), [])
    })), [])
    profiling_scans = optional(list(object({
      scan_id      = string
      lake_id      = string
      display_name = optional(string)
      description  = optional(string)
      data_source  = string
    })), [])
  })
  default = {}
}

variable "labels" {
  description = "Labels to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

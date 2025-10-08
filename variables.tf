/**
 * Copyright 2025 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# ==============================================================================
# REQUIRED VARIABLES
# ==============================================================================

variable "project_id" {
  description = "The GCP project ID where Dataplex resources will be created"
  type        = string
}

variable "region" {
  description = "The GCP region for regional resources"
  type        = string
}

variable "location" {
  description = "The GCP location for Dataplex resources"
  type        = string
}

# ==============================================================================
# MODULE ENABLE FLAGS
# ==============================================================================

variable "enable_manage_lakes" {
  description = "Enable the manage lakes module (lakes, zones, assets)"
  type        = bool
  default     = true
}

variable "enable_metadata" {
  description = "Enable the metadata management module (catalog, glossaries)"
  type        = bool
  default     = true
}

variable "enable_governance" {
  description = "Enable the governance module (data quality, profiling, monitoring)"
  type        = bool
  default     = true
}

# ==============================================================================
# MANAGE LAKES VARIABLES
# ==============================================================================

variable "enable_manage" {
  description = "Enable lake management (lakes, zones, assets)"
  type        = bool
  default     = true
}

variable "enable_secure" {
  description = "Enable security features (IAM, encryption, audit logging)"
  type        = bool
  default     = true
}

variable "enable_process" {
  description = "Enable data processing (Spark jobs, tasks)"
  type        = bool
  default     = true
}

variable "lakes" {
  description = "List of Dataplex lakes to create with their zones"
  type = list(object({
    lake_id      = string
    display_name = optional(string)
    description  = optional(string)
    labels       = optional(map(string), {})
    zones = optional(list(object({
      zone_id       = string
      type          = string # RAW or CURATED
      display_name  = optional(string)
      description   = optional(string)
      location_type = optional(string, "SINGLE_REGION")
      # Support for existing resources
      existing_bucket  = optional(string)     # For RAW zones - name of existing GCS bucket
      existing_dataset = optional(string)     # For CURATED zones - ID of existing BigQuery dataset
      create_storage   = optional(bool, true) # Set to false to use existing resources

      # Custom names for new resources (only used when create_storage = true)
      bucket_name = optional(string) # Custom GCS bucket name (default: "${project_id}-${lake_id}-${zone_id}")
      dataset_id  = optional(string) # Custom BigQuery dataset ID (default: "${lake_id}_${zone_id}")
    })), [])
  }))
  default = []
}

variable "iam_bindings" {
  description = "IAM bindings for Dataplex lakes"
  type = list(object({
    lake_id = string
    role    = string
    members = list(string)
  }))
  default = []
}

variable "spark_jobs" {
  description = "List of Spark jobs to create as Dataplex tasks"
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

# ==============================================================================
# METADATA MANAGEMENT VARIABLES
# ==============================================================================

variable "enable_catalog" {
  description = "Enable catalog functionality (entry groups, entry types, aspect types)"
  type        = bool
  default     = true
}

variable "enable_glossaries" {
  description = "Enable business glossaries (stored in BigQuery)"
  type        = bool
  default     = true
}

variable "entry_groups" {
  description = "List of entry groups to create in the catalog"
  type = list(object({
    entry_group_id = string
    display_name   = optional(string)
    description    = optional(string)
  }))
  default = []
}

variable "glossaries" {
  description = "List of business glossaries with terms"
  type = list(object({
    glossary_id  = string
    display_name = optional(string)
    description  = optional(string)
    terms = optional(list(object({
      term_id      = string
      display_name = optional(string)
      description  = optional(string)
    })), [])
  }))
  default = []
}

# ==============================================================================
# GOVERNANCE VARIABLES
# ==============================================================================

variable "enable_profiling" {
  description = "Enable data profiling scans"
  type        = bool
  default     = true
}

variable "enable_quality" {
  description = "Enable data quality scans"
  type        = bool
  default     = true
}

variable "enable_monitoring" {
  description = "Enable monitoring and alerting for data quality"
  type        = bool
  default     = true
}

variable "quality_scans" {
  description = "List of data quality scans to create"
  type = list(object({
    scan_id      = string
    lake_id      = string
    display_name = optional(string)
    description  = optional(string)
    data_source  = string
    rules = optional(list(object({
      rule_type = string # NON_NULL, UNIQUENESS, REGEX, RANGE, SET_MEMBERSHIP
      column    = optional(string)
      threshold = optional(number, 0.95)
      dimension = optional(string, "COMPLETENESS")
    })), [])
  }))
  default = []
}

variable "profiling_scans" {
  description = "List of data profiling scans to create"
  type = list(object({
    scan_id      = string
    lake_id      = string
    display_name = optional(string)
    description  = optional(string)
    data_source  = string
  }))
  default = []
}

# ==============================================================================
# COMMON VARIABLES
# ==============================================================================

variable "labels" {
  description = "Labels to apply to all resources"
  type        = map(string)
  default     = {}
}

# ==============================================================================
# PROCESS - SPARK SQL TASKS
# ==============================================================================

variable "spark_sql_jobs" {
  description = "List of Spark SQL jobs to create"
  type = list(object({
    job_id       = string
    lake_id      = string
    display_name = optional(string)
    description  = optional(string)
    sql_script   = optional(string)
    sql_file_uri = optional(string)
    file_uris    = optional(list(string))
    archive_uris = optional(list(string))
    schedule     = optional(string)
  }))
  default = []
}

# ==============================================================================
# PROCESS - NOTEBOOK TASKS
# ==============================================================================

variable "notebook_jobs" {
  description = "List of Jupyter notebook jobs to create"
  type = list(object({
    job_id          = string
    lake_id         = string
    display_name    = optional(string)
    description     = optional(string)
    notebook_uri    = string
    file_uris       = optional(list(string))
    archive_uris    = optional(list(string))
    container_image = optional(string)
    schedule        = optional(string)
  }))
  default = []
}

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

variable "enable_profiling" {
  description = "Enable data profiling"
  type        = bool
  default     = true
}

variable "enable_quality" {
  description = "Enable data quality checks"
  type        = bool
  default     = true
}

variable "enable_monitoring" {
  description = "Enable monitoring and alerting"
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
      rule_type = string
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

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}

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

variable "quality_scans" {
  description = "List of data quality scans to create"
  type = list(object({
    scan_id      = string
    lake_id      = string
    display_name = optional(string)
    description  = optional(string)
    data_source  = string
    rules = optional(list(object({
      rule_type  = string
      column     = optional(string)
      threshold  = optional(number, 0.95)
      dimension  = optional(string, "COMPLETENESS")
    })), [])
  }))
  default = []
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}

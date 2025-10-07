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

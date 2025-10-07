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
    })), [])
  }))
  default = []
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}

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

variable "entry_groups" {
  description = "List of entry groups to create"
  type = list(object({
    entry_group_id = string
    display_name   = optional(string)
    description    = optional(string)
  }))
  default = []
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}

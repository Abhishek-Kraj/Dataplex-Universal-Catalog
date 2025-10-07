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

variable "glossaries" {
  description = "List of glossaries to create"
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

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}

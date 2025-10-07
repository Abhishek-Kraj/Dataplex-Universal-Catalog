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

variable "enable_search" {
  description = "Enable search functionality"
  type        = bool
  default     = true
}

variable "enable_taxonomy" {
  description = "Enable taxonomy management"
  type        = bool
  default     = true
}

variable "enable_templates" {
  description = "Enable metadata templates"
  type        = bool
  default     = true
}

variable "search_scope" {
  description = "Search scope (PROJECT, ORGANIZATION)"
  type        = string
  default     = "PROJECT"
}

variable "search_result_limit" {
  description = "Maximum number of search results"
  type        = number
  default     = 100
}

variable "taxonomy_display_name" {
  description = "Display name for the taxonomy"
  type        = string
  default     = "Dataplex Taxonomy"
}

variable "policy_tags" {
  description = "List of policy tags to create"
  type        = list(string)
  default     = []
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}

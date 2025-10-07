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

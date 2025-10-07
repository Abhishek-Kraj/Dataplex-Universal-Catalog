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

variable "search_scope" {
  description = "Search scope (PROJECT, ORGANIZATION)"
  type        = string
  default     = "PROJECT"
  validation {
    condition     = contains(["PROJECT", "ORGANIZATION"], var.search_scope)
    error_message = "Search scope must be either PROJECT or ORGANIZATION."
  }
}

variable "search_result_limit" {
  description = "Maximum number of search results"
  type        = number
  default     = 100
  validation {
    condition     = var.search_result_limit > 0 && var.search_result_limit <= 1000
    error_message = "Search result limit must be between 1 and 1000."
  }
}

variable "search_dataset_id" {
  description = "BigQuery dataset ID for search results"
  type        = string
  default     = "dataplex_search_results"
}

variable "enable_search_history" {
  description = "Enable search history tracking"
  type        = bool
  default     = true
}

variable "search_history_retention_days" {
  description = "Number of days to retain search history"
  type        = number
  default     = 90
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}

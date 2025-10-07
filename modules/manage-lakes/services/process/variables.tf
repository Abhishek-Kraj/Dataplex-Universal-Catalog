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

variable "spark_jobs" {
  description = "List of Spark jobs to create"
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

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}

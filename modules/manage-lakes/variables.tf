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

variable "enable_manage" {
  description = "Enable lake management"
  type        = bool
  default     = true
}

variable "enable_secure" {
  description = "Enable security features"
  type        = bool
  default     = true
}

variable "enable_process" {
  description = "Enable data processing"
  type        = bool
  default     = true
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

variable "iam_bindings" {
  description = "List of IAM bindings"
  type = list(object({
    lake_id = string
    role    = string
    members = list(string)
  }))
  default = []
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

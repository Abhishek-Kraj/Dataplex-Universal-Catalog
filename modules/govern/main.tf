# Govern Module - Data Profiling, Quality, and Monitoring

# Data Profiling Service
module "profiling" {
  count  = var.enable_profiling ? 1 : 0
  source = "./services/profiling"

  project_id      = var.project_id
  region          = var.region
  location        = var.location
  profiling_scans = var.profiling_scans
  labels          = var.labels
}

# Data Quality Service
module "quality" {
  count  = var.enable_quality ? 1 : 0
  source = "./services/quality"

  project_id    = var.project_id
  region        = var.region
  location      = var.location
  quality_scans = var.quality_scans
  labels        = var.labels
}

# Monitoring Service
module "monitoring" {
  count  = var.enable_monitoring ? 1 : 0
  source = "./services/monitoring"

  project_id = var.project_id
  region     = var.region
  location   = var.location
  labels     = var.labels
}

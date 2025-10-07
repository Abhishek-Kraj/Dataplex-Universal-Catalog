# Manage Lakes Module - Manage, Secure, Process

# Manage Service - Lakes, Zones, Assets
module "manage" {
  count  = var.enable_manage ? 1 : 0
  source = "./services/manage"

  project_id = var.project_id
  region     = var.region
  location   = var.location
  lakes      = var.lakes
  labels     = var.labels
}

# Secure Service - IAM, Encryption, Access Policies
module "secure" {
  count  = var.enable_secure ? 1 : 0
  source = "./services/secure"

  project_id   = var.project_id
  region       = var.region
  location     = var.location
  iam_bindings = var.iam_bindings
  labels       = var.labels

  depends_on = [module.manage]
}

# Process Service - Data Processing Tasks, Spark Jobs
module "process" {
  count  = var.enable_process ? 1 : 0
  source = "./services/process"

  project_id = var.project_id
  region     = var.region
  location   = var.location
  spark_jobs = var.spark_jobs
  labels     = var.labels

  depends_on = [module.manage]
}

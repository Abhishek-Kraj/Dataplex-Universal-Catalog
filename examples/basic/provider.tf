provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = file("sa-key.json")
}

provider "google-beta" {
  project     = var.project_id
  region      = var.region
  credentials = file("sa-key.json")
}

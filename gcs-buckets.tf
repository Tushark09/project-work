/* Static Web App Buckets */

module "cloud_storage_buckets" {
  source  = "terraform-google-modules/cloud-storage/google"
  version = "6.1.0"
  project_id  = var.project_id
  names = [     
    "gcs-qsight-${var.name_project}-${var.name_region}-termsofuse"
  ]
  force_destroy = {
    "gcs-qsight-${var.name_project}-${var.name_region}-termsofuse" = true
  }
  location = "US"
}

module "cloud_storage_buckets_public" {
  source  = "terraform-google-modules/cloud-storage/google"
  version = "6.1.0"
  project_id  = var.project_id
  names = [     
    "gcs-qsight-${var.name_project}-${var.name_region}-kanban-api"
  ]
  force_destroy = {
    "gcs-qsight-${var.name_project}-${var.name_region}-kanban-api" = true
  }
  location = "US"
  set_viewer_roles = true
  viewers = ["allUsers"]
}




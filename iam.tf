
resource "google_project_iam_member" "miglab_admin_roles" {
  count   = length(var.miglab_admin_roles)
  project = var.project_id
  role    = var.miglab_admin_roles[count.index]
  member  = "group:gcp-proj-qsight-miglab-admin@owens-minor.com"
}

resource "google_project_iam_member" "iap_user_permissions" {
  count   = length(var.iap_user_roles)
  project = var.project_id
  role    = var.iap_user_roles[count.index]
  member  = "user:Abhinav.Hasoriya@owens-minor.com"
}

resource "google_project_iam_member" "logging_sa_roles" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:service-${var.project_number}@gcp-sa-logging.iam.gserviceaccount.com"
}



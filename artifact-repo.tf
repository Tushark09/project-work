# Create Artifact Registry repositories
resource "google_artifact_registry_repository" "cloud_run_repo" {
  location      = var.region
  repository_id = "ar-${var.name_project}-${var.name_region}-cloud-run"
  description   = "Docker repository for Cloud run services"
  format        = "DOCKER"
  depends_on = [ module.project_services ]
}
module "vm_service_account" {
  source  = "terraform-google-modules/service-accounts/google//modules/simple-sa"
  version = "4.4.2"
  project_id    = var.project_id
  name          = "svc-ce-qsight-${var.name_project}-${var.name_region}"
  description   = "Compute Engine Service Account"
  display_name  = "Compute Engine Service Account"
  project_roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/storage.admin",
    "roles/storage.objectAdmin",
  ]
}

# Create a service account key
resource "google_service_account_key" "vm_sa_key" {
  service_account_id = module.vm_service_account.email
}

# Create a secret in Secret Manager
resource "google_secret_manager_secret" "vm_sa_key_secret" {
  secret_id = "vm-sa-${var.name_project}-${var.name_region}-key-secret"
  
  replication {
    user_managed {
      replicas {
        location = "us-central1"
      }
      replicas {
        location = "us-east1"
      }
    }
  }
} 

# Store the service account key JSON in the secret
resource "google_secret_manager_secret_version" "vm_sa_key_secret_version" {
  secret      = google_secret_manager_secret.vm_sa_key_secret.id
  secret_data = base64decode(google_service_account_key.vm_sa_key.private_key)
}

module "secret_manager_service_account" {
  source  = "terraform-google-modules/service-accounts/google//modules/simple-sa"
  version = "4.4.2"
  project_id    = var.project_id
  name          = "svc-sm-qsight-${var.name_project}"
  description   = "Secret Manager service account for pipeline"
  display_name  = "Secret Manager service account"
  project_roles = [
    "roles/secretmanager.admin"
  ]
}

# Create a service account key
resource "google_service_account_key" "sm_sa_key" {
  service_account_id = module.secret_manager_service_account.email
}

# Create a secret in Secret Manager
resource "google_secret_manager_secret" "sm_sa_key_secret" {
  secret_id = "sm-sa-${var.name_project}-${var.name_region}-key-secret"
  
  replication {
    user_managed {
      replicas {
        location = "us-central1"
      }
      replicas {
        location = "us-east1"
      }
    }
  }
}

# Store the service account key JSON in the secret
resource "google_secret_manager_secret_version" "sm_sa_key_secret_version" {
  secret      = google_secret_manager_secret.sm_sa_key_secret.id
  secret_data = base64decode(google_service_account_key.sm_sa_key.private_key)
}



module "cloud_run_service_account" {
  source  = "terraform-google-modules/service-accounts/google//modules/simple-sa"
  version = "4.4.2"
  project_id    = var.project_id
  name          = "svc-clrun-qsight-${var.name_project}"
  description   = "Cloud run service account"
  display_name  = "Cloud run service account"
  project_roles = [
    "roles/secretmanager.secretAccessor",
    "roles/logging.logWriter",
    "roles/storage.objectViewer",
    "roles/storage.admin",
    "roles/storage.objectAdmin",
    "roles/dns.admin"
  ]
}

# Create a service account key
resource "google_service_account_key" "clrun_sa_key" {
  service_account_id = module.cloud_run_service_account.email
}

# Create a secret in Secret Manager
resource "google_secret_manager_secret" "clrun_sa_key_secret" {
  secret_id = "clrun-sa-${var.name_project}-${var.name_region}-key-secret"
  
  replication {
    user_managed {
      replicas {
        location = "us-central1"
      }
      replicas {
        location = "us-east1"
      }
    }
  }
}

# Store the service account key JSON in the secret
resource "google_secret_manager_secret_version" "clrun_sa_key_secret_version" {
  secret      = google_secret_manager_secret.clrun_sa_key_secret.id
  secret_data = base64decode(google_service_account_key.clrun_sa_key.private_key)
}


module "cloud_run_service_account_pipeline" {
  source  = "terraform-google-modules/service-accounts/google//modules/simple-sa"
  version = "4.4.2"
  project_id    = var.project_id
  name          = "svc-clrun-pipeline-${var.name_project}"
  description   = "Cloud run service account for pipeline"
  display_name  = "Cloud run service account for pipeline"
  project_roles = [
    "roles/run.admin",
    "roles/artifactregistry.writer",
    "roles/iam.serviceAccountUser",
    "roles/artifactregistry.repoAdmin",
    "roles/secretmanager.secretAccessor",
    "roles/logging.logWriter",
    "roles/cloudfunctions.admin",
    "roles/iam.serviceAccountUser",
    "roles/pubsub.editor",
    "roles/logging.configWriter",
    "roles/storage.objectViewer",
    "roles/monitoring.dashboardEditor",
    "roles/monitoring.viewer",
    "roles/monitoring.metricWriter",
    "roles/monitoring.editor"
  ]
}


# Create a service account key
resource "google_service_account_key" "clrun_pipeline_sa_key" {
  service_account_id = module.cloud_run_service_account_pipeline.email
}

# Create a secret in Secret Manager
resource "google_secret_manager_secret" "clrun_pipeline_sa_key_secret" {
  secret_id = "clrun-spipeline-sa-${var.name_project}-${var.name_region}-key-secret"
  
  replication {
    user_managed {
      replicas {
        location = "us-central1"
      }
      replicas {
        location = "us-east1"
      }
    }
  }
}

# Store the service account key JSON in the secret
resource "google_secret_manager_secret_version" "clrun_pipeline_sa_key_secret_version" {
  secret      = google_secret_manager_secret.clrun_pipeline_sa_key_secret.id
  secret_data = base64decode(google_service_account_key.clrun_pipeline_sa_key.private_key)
}


module "cloud_storage_service_account" {
  source  = "terraform-google-modules/service-accounts/google//modules/simple-sa"
  version = "4.4.2"
  project_id    = var.project_id
  name          = "svc-gcs-qsight-${var.name_project}"
  description   = "cloud_storage_service_account"
  display_name  = "cloud_storage_service_account"
  project_roles = [
    "roles/storage.objectAdmin"
  ]
}


# Create a service account key
resource "google_service_account_key" "gcs_sa_key" {
  service_account_id = module.cloud_storage_service_account.email
}

# Create a secret in Secret Manager
resource "google_secret_manager_secret" "gcs_sa_key_secret" {
  secret_id = "gcs-sa-${var.name_project}-${var.name_region}-key-secret"
  
  replication {
    user_managed {
      replicas {
        location = "us-central1"
      }
      replicas {
        location = "us-east1"
      }
    }
  }
}

# Store the service account key JSON in the secret
resource "google_secret_manager_secret_version" "gcs_sa_key_secret_version" {
  secret      = google_secret_manager_secret.gcs_sa_key_secret.id
  secret_data = base64decode(google_service_account_key.gcs_sa_key.private_key)
}
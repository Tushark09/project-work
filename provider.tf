terraform {
  cloud {
    
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0, < 7"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 6.0, < 7"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.1"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google" {
  alias   = "host"
  project = var.host_project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}
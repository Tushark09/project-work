# Local variables
locals {
  termsofusage_bucket = "gcs-qsight-${var.name_project}-${var.name_region}-termsofuse"
}



# PubSub module
module "pubsub" {
  source  = "terraform-google-modules/pubsub/google"
  version = "7.0.0"

  project_id = var.project_id  
  topic      = "ps-topic-${var.name_project}-termsofusage-change-listener"

  push_subscriptions = [
    {
      name                    = "ps-subscription-${var.name_project}-termsofusage-change-listener"  
      push_endpoint          = "${var.pubsub_termsofusage_endpoint}"
      ack_deadline_seconds   = 20
      x-goog-version         = "v1"
      expiration_policy      = ""  # Empty string means never expire
      maximum_backoff        = "600s"
      minimum_backoff        = "10s"
      enable_message_ordering = false
    }
  ]
} 


module "pubsub_fixed_reader" {
  source  = "terraform-google-modules/pubsub/google" 
  version = "7.0.0"
  
  project_id = var.project_id
  topic      = "ps-topic-${var.name_project}-fixed-reader-listener"
  
  push_subscriptions = [
    {
      name                    = "ps-subscription-${var.name_project}-fixed-reader-listener" 
      push_endpoint          = "${var.pubsub_fixed_reader_endpoint}"
      ack_deadline_seconds   = 20
      x-goog-version         = "v1"
      expiration_policy      = ""  # Empty string means never expire
      maximum_backoff        = "600s"
      minimum_backoff        = "10s"
      enable_message_ordering = false
    }
  ]
}



# Get the bucket reference
data "google_storage_bucket" "termsofusage" {
  name = local.termsofusage_bucket
  
  depends_on = [
    module.cloud_storage_buckets
  ]
}

# Create the Cloud Storage notification
resource "google_storage_notification" "notification" {
  bucket         = data.google_storage_bucket.termsofusage.name
  payload_format = "JSON_API_V1"
  topic         = module.pubsub.topic
  event_types   = ["OBJECT_FINALIZE"]
  
  #object_name_prefix = "QSIGHTTERMSOFUSE"
}

# Grant the Cloud Storage service account permission to publish to Pub/Sub
data "google_storage_project_service_account" "gcs_account" {
}

resource "google_project_iam_binding" "pubsub_publisher" {
  project = var.project_id 
  role    = "roles/pubsub.publisher"
  members = ["serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"]
}

# Outputs
output "termsofusage_bucket_name" {
  description = "The name of the termsofusage bucket"
  value       = data.google_storage_bucket.termsofusage.name
}

output "topic_name" {
  description = "The created Pub/Sub topic name"
    value = module.pubsub.topic
   
}

output "subscription_names" {
  description = "The created Pub/Sub subscription names"
    value = module.pubsub.subscription_names
    
  
}
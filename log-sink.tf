# Create a log sink
resource "google_logging_project_sink" "health_check_errors" {
  name = "health-check-errors-sink"
  destination = "pubsub.googleapis.com/projects/${var.project_id}/topics/${module.pubsub-hc-error.topic}"
  filter = var.health_check_filter
  unique_writer_identity = true
}

# PubSub module
module "pubsub-hc-error" {
  source  = "terraform-google-modules/pubsub/google"
  version = "7.0.0"

  project_id = var.project_id  
  topic      = "health-check-errors-topic"

  push_subscriptions = [
    {
      name                    = "health-check-errors-subscription"
      push_endpoint          = var.health-check-errors_push_endpoint
      ack_deadline_seconds    = 20
      x-goog-version         = "v1"
      expiration_policy      = "" 
      maximum_backoff        = "600s"
      minimum_backoff        = "10s"
      enable_message_ordering = false
    }
  ]
}


# Create a log sink for dynatrace
resource "google_logging_project_sink" "dynatrace" {
  name = "Dynatrace-sink"
  destination = "pubsub.googleapis.com/projects/${var.project_id}/topics/${module.pubsub-dynatrace.topic}"
  filter = var.dynatrace_filter
  unique_writer_identity = true
}

# PubSub module
module "pubsub-dynatrace" {
  source  = "terraform-google-modules/pubsub/google"
  version = "7.0.0"

  project_id = var.project_id  
  topic      = "dynatrace-topic"

  pull_subscriptions = [
    {
      name                       = "dynatrace-subscription"
      ack_deadline_seconds       = 120
      expiration_policy          = "" 
      message_retention_duration = "86400s"
      minimum_backoff            ="0s"
      enable_message_ordering    = false                
      enable_exactly_once        = false                 
      dead_letter_policy         = null                  
      retain_acked_messages      = false                 
      filter                     = ""                   
    }
  ]
}
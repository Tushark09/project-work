# Global Health Check
resource "google_compute_health_check" "ilb-int-hc" {
  provider = google-beta
  name     = "gilb-int-http-health-check"
  http_health_check {
    port_specification = "USE_SERVING_PORT"
  }
}

# Global Backend Service
resource "google_compute_backend_service" "ilb-int-backend" {
  name                  = "gilb-int-backend-service-${var.name_project}"
  provider              = google-beta
  protocol              = "HTTP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  timeout_sec           = 10
  health_checks         = [google_compute_health_check.ilb-int-hc.id]

  backend {
    group              = google_compute_instance_group.umig_int_server["us-central1-a"].self_link
    balancing_mode     = "UTILIZATION"
    capacity_scaler    = 1.0
  }

  backend {
    group              = google_compute_instance_group.umig_int_server_dr["us-east5-a"].self_link
    balancing_mode     = "UTILIZATION"
    capacity_scaler    = 1.0
  }
}


# Global URL Map
resource "google_compute_url_map" "ilb-int-url-map" {
  provider        = google-beta
  name            = "gilb-int-url-map-${var.name_project}"
  default_service = google_compute_backend_service.ilb-int-backend.id
}

# Global Target HTTP Proxy
resource "google_compute_target_http_proxy" "ilb-int-target-proxy" {
  provider = google-beta
  name     = "gilb-int-target-http-proxy-${var.name_project}"
  url_map  = google_compute_url_map.ilb-int-url-map.id
}

# Global Forwarding Rule for us-central1
# resource "google_compute_global_forwarding_rule" "fwd_rule_a" {
#   provider                = google-beta
#   ip_protocol            = "TCP"
#   load_balancing_scheme  = "INTERNAL_MANAGED"
#   name                   = "gil7forwarding-int-rule-usc1"
#   network               = var.network
#   port_range            = "31000"
#   target                = google_compute_target_http_proxy.ilb-int-target-proxy.id
#   subnetwork            = var.subnet_ilb_usc1
# }

# # Global Forwarding Rule for us-east5
# resource "google_compute_global_forwarding_rule" "fwd_rule_b" {
#   provider                = google-beta
#   ip_protocol            = "TCP"
#   load_balancing_scheme  = "INTERNAL_MANAGED"
#   name                   = "gil7forwarding-int-rule-use5"
#   network               = var.network
#   port_range            = "31000"
#   target                = google_compute_target_http_proxy.ilb-int-target-proxy.id
#   subnetwork            = var.subnet_ilb_use5
# }

# Proxy Subnet Data Sources (still needed for subnet configurations)
data "google_compute_subnetwork" "proxy_subnet_usc1" {
  name    = "sb-qsight-ilb-proxy-only-usc1-1"  
  region  = "us-central1"
  project = "proj-omi-host-qa-d268"
}

data "google_compute_subnetwork" "proxy_subnet_use5" {
  name    = "sb-qsight-ilb-proxy-only-use5-1"  
  region  = "us-east5"
  project = "proj-omi-host-qa-d268"
}

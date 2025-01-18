# Create a static IP address for the load balancer
resource "google_compute_global_address" "lb_qsight_swa_kanban_ip" {
  name         = "static-lb-swa-kanban-${var.name_project}-global-ip"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}



# Create a URL map to route requests to the appropriate backend
resource "google_compute_url_map" "url_map_qsight_swa_kanban" {
  count = var.is_dr_enabled ? 0 : 1
  name            = "glb-${var.name_project}-swa-kanban"
  default_service = module.glb-qsight-swa-kanban[0].backend_services["cr-kanban-web"].self_link
}


resource "google_compute_region_network_endpoint_group" "cr-kanban-web" {
  name                  = "neg-cr-kanban-web"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = "cr-web-mf-kanban-api-qsight-${var.environment}-${var.name_region}"
  }
}


module "glb-qsight-swa-kanban" {
  count = var.is_dr_enabled ? 0 : 1
  source            = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  version           = "12.0.0"


  project = var.project_id
  name    = "glb-qsight-${var.environment}-swa-kanban"

  create_address   = false
  address          = google_compute_global_address.lb_qsight_swa_kanban_ip.address
  ssl              = true
  ssl_certificates = [google_compute_managed_ssl_certificate.ssl_swa.self_link]



  backends = {
    cr-kanban-web = {
      protocol                        = "HTTPS"
      timeout_sec  = 120  
      enable_cdn   = true 
      cdn_policy = {
        cache_mode                   = "CACHE_ALL_STATIC"
        default_ttl                  = 86400
        max_ttl                      = 604800
        client_ttl                   = 86400
        negative_caching             = false
        signed_url_cache_max_age_sec = 7200
        negative_caching_policy      = null
        cache_key_policy             = null
        bypass_cache_on_request_headers = []
        cache_key_policy = {
          include_host           = true
          include_protocol       = true
          include_query_string   = true
          query_string_blacklist = []
          query_string_whitelist = []
          include_http_headers   = []
          include_named_cookies  = []
        }
      }
      security_policy       = module.cloud-armor.policy.name
      log_config = {
        enable = false
        sample_rate = 1.0
      }
      groups = [
        {
          group = google_compute_region_network_endpoint_group.cr-kanban-web.id
        }
      ]

      iap_config = {
        enable = false
      }
    }
  }
  create_url_map = false
  url_map        = google_compute_url_map.url_map_qsight_swa_kanban[0].self_link

  http_forward   = false
  https_redirect = true
  load_balancing_scheme = "EXTERNAL_MANAGED"
}
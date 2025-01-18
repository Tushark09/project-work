# Create a static IP address for the load balancer
resource "google_compute_global_address" "lb_qsight_swa_knowledgecenter_ip" {
  name         = "static-lb-swa-knowledgecenter-${var.name_project}-global-ip"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}

resource "google_compute_region_network_endpoint_group" "cr-knowledgecenter-web" {
  name                  = "neg-cr-knowledgecenter-web"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = "cr-web-mf-knowledgecenter-api-qsight-${var.environment}-${var.name_region}"
  }
}

# Create a URL map to route requests to the appropriate backend
resource "google_compute_url_map" "glb-knowledgecenter-web" {
  count = var.is_dr_enabled ? 0 : 1
  name            = "um-glb-qsight-${var.environment}-knowledgecenter-web"
  default_service = module.glb-knowledgecenter-web[0].backend_services["knowledgecenter-web"].self_link
}


module "glb-knowledgecenter-web" {
  count = var.is_dr_enabled ? 0 : 1
  source            = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  version           = "12.0.0"
  project           = var.project_id
  name              = "glb-qsight-${var.environment}-knowledgecenter-web"
  address           = google_compute_global_address.lb_qsight_swa_knowledgecenter_ip.address
  create_address    = false
  ssl               = true
  ssl_certificates  = [google_compute_managed_ssl_certificate.ssl_swa.self_link]
  https_redirect                  = true
  backends = {
    knowledgecenter-web = {
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
      }
      security_policy       = module.cloud-armor.policy.name
      log_config = {
        enable = false
        sample_rate = 1.0
      }
      groups = [
        {
          group = google_compute_region_network_endpoint_group.cr-knowledgecenter-web.id
        }
      ]

      iap_config = {
        enable = false
      }
      cdn_policy = {
        cache_mode                    = "USE_ORIGIN_HEADERS"
        default_ttl                   = 3600
        client_ttl                    = 3600
        max_ttl                       = 86400
        negative_caching             = false
        serve_while_stale           = 0
        signed_url_cache_max_age_sec = 7200
        negative_caching_policy     = null
        cache_key_policy            = null
        bypass_cache_on_request_headers = []
      }
    }
  }
  create_url_map = false
  url_map        = google_compute_url_map.glb-knowledgecenter-web[0].self_link
  http_forward   = false
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

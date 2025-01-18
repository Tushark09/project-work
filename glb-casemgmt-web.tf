

# Create a static IP address for the load balancer
resource "google_compute_global_address" "glb-casemgmt-web" {
  name         = "cga-glb-qsight-${var.name_project}-casemgmt-web-ip"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}


resource "google_compute_region_network_endpoint_group" "cr-casemgmt-web" {
  name                  = "neg-cr-casemgmt-web"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = "cr-casemgmt-web-qsight-${var.environment}-${var.name_region}"
  }
}

# Create a URL map to route requests to the appropriate backend
resource "google_compute_url_map" "glb-casemgmt-web" {
  count = var.is_dr_enabled ? 0 : 1
  name            = "um-glb-qsight-${var.environment}-casemgmt-web"
  default_service = module.glb-casemgmt-web[0].backend_services["casemgmt-web"].self_link
}


resource "google_compute_managed_ssl_certificate" "ssl_omapps" {
  name        = "sl-cert-${var.environment}-casemgmt-${var.project_name}"
  managed {
    domains = [var.glb_casemgmt_web_domain]
  }
}

module "glb-casemgmt-web" {
  count             = var.is_dr_enabled ? 0 : 1
  source            = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  version           = "12.0.0"
  project           = var.project_id
  name              = "glb-qsight-${var.environment}-casemgmt-web"
  address           = google_compute_global_address.glb-casemgmt-web.address
  create_address    = false
  ssl               = true
  ssl_certificates  = [google_compute_managed_ssl_certificate.ssl_omapps.self_link]
  https_redirect                  = true
  backends = {
    casemgmt-web = {
      protocol                        = "HTTPS"
      timeout_sec  = 120  
      enable_cdn   = true 
      security_policy       = module.cloud-armor.policy.name
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
      log_config = {
        enable = true
        sample_rate = 1.0
      }
      groups = [
        {
          group = google_compute_region_network_endpoint_group.cr-casemgmt-web.id
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
  url_map        = google_compute_url_map.glb-casemgmt-web[0].self_link
  load_balancing_scheme = "EXTERNAL_MANAGED"
}
resource "google_compute_url_map" "url_map_qsight_swa_kanban_dr" {
  count = var.is_dr_enabled ? 1 : 0
  name            = "glb-${var.name_project}-swa-kanban"
  default_service = module.glb-qsight-swa-kanban-dr[0].backend_services["cr-kanban-web"].self_link
}

resource "google_compute_region_network_endpoint_group" "cr-kanban-web-dr" {
  name                  = "neg-cr-kanban-web-dr"
  network_endpoint_type = "SERVERLESS"
  region                = var.dr_region
  cloud_run {
    service = "cr-web-mf-kanban-api-qsight-${var.environment}-${var.name_region_dr}"
  }
}

module "glb-qsight-swa-kanban-dr" {
  count = var.is_dr_enabled ? 1 : 0
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
      }
      security_policy       = module.cloud-armor.policy.name
      log_config = {
        enable = false
        sample_rate = 1.0
      }
      outlier_detection = {
        base_ejection_time = {
          seconds = 120
        }
        consecutive_errors                = 5
        consecutive_gateway_failure       = 3
        enforcing_consecutive_errors      = 100
        enforcing_success_rate = null
        enforcing_consecutive_gateway_failure = 100
        interval = {
          seconds = 10
        }
        max_ejection_percent              = 50
      }
      groups = [
        {
          group = google_compute_region_network_endpoint_group.cr-kanban-web.id
        },
        {
          group = google_compute_region_network_endpoint_group.cr-kanban-web-dr.id
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
  url_map        = google_compute_url_map.url_map_qsight_swa_kanban_dr[0].self_link

  http_forward   = false
  https_redirect = true
  load_balancing_scheme = "EXTERNAL_MANAGED"
}
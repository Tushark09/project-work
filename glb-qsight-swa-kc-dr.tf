resource "google_compute_url_map" "glb-knowledgecenter-web-dr" {
  count = var.is_dr_enabled ? 1 : 0
  name            = "um-glb-qsight-${var.environment}-kc-web"
  default_service = module.glb-knowledgecenter-web-dr[0].backend_services["kc"].self_link
}

resource "google_compute_region_network_endpoint_group" "cr-knowledgecenter-web-dr" {
  name                  = "neg-cr-knowledgecenter-web-dr"
  network_endpoint_type = "SERVERLESS"
  region                = var.dr_region
  cloud_run {
    service = "cr-web-mf-knowledgecenter-api-qsight-${var.environment}-${var.name_region_dr}"
  }
}


module "glb-knowledgecenter-web-dr" {
  count = var.is_dr_enabled ? 1 : 0
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
    kc = {
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
          group = google_compute_region_network_endpoint_group.cr-knowledgecenter-web.id
        },
        {
          group = google_compute_region_network_endpoint_group.cr-knowledgecenter-web-dr.id
        }
      ]

      iap_config = {
        enable = false
      }
    }
  }
  create_url_map = false
  url_map        = google_compute_url_map.glb-knowledgecenter-web-dr[0].self_link
  http_forward   = false
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

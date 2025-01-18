resource "google_compute_url_map" "url_map_qsight_dr" {
  count = var.is_dr_enabled ? 1 : 0
  name            = "glb-${var.name_project}-qsight-web"
  default_service = module.glb-qsight-web-dr[0].backend_services["cr-container-web"].self_link

  host_rule {
    hosts        = ["${var.environment}.web.qsight.net"]
    path_matcher = "qsight-paths"
  }

  path_matcher {
    name            = "qsight-paths"
    default_service = module.glb-qsight-web-dr[0].backend_services["cr-container-web"].self_link
    
    path_rule {
      paths   = ["/BarcodeSupport", "/BarcodeSupport/*"]
      service = module.glb-qsight-web-dr[0].backend_services["cr-adminportal-web"].self_link
    }
    

    path_rule {
      paths   = ["/fulfillment", "/fulfillment/*"]
      service = module.glb-qsight-web-dr[0].backend_services["cr-app-crossdock"].self_link
    }

    path_rule {
      paths   = ["/*"]
      service = module.glb-qsight-web-dr[0].backend_services["cr-container-web"].self_link
    } 
  }
}

resource "google_compute_region_network_endpoint_group" "cr-container-web-dr" {
  name                  = "neg-cr-container-web-dr"
  network_endpoint_type = "SERVERLESS"
  region                = var.dr_region
  cloud_run {
    service = "cr-web-mf-container-api-qsight-${var.environment}-${var.name_region_dr}"
  }
}

resource "google_compute_region_network_endpoint_group" "cr-app-crossdock-dr" {
  name                  = "neg-cr-app-crossdock-dr"
  network_endpoint_type = "SERVERLESS"
  region                = var.dr_region
  cloud_run {
    service = "cr-app-crossdock-qsight-${var.environment}-${var.name_region_dr}"
  }
}

resource "google_compute_region_network_endpoint_group" "cr-web-mf-container-dr" {
  name                  = "neg-cr-web-mf-container-dr"
  network_endpoint_type = "SERVERLESS"
  region                = var.dr_region
  cloud_run {
    service = "cr-web-mf-container-api-qsight-${var.environment}-${var.name_region_dr}"
  }
}

resource "google_compute_region_network_endpoint_group" "cr-adminportal-web-dr" {
  name                  = "neg-cr-adminportal-web-dr"
  network_endpoint_type = "SERVERLESS"
  region                = var.dr_region
  cloud_run {
    service = "cr-web-mf-adminportal-api-qsight-${var.environment}-${var.name_region_dr}"
  }
}

module "glb-qsight-web-dr" {
  count = var.is_dr_enabled ? 1 : 0
  source            = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  version           = "12.0.0"
  project = var.project_id
  name    = "glb-qsight-${var.environment}-qsight-web"
  create_address   = false
  address          = google_compute_global_address.lb_qsight_web_ip.address
  ssl              = true
  ssl_certificates = [google_compute_managed_ssl_certificate.ssl_qsight_web.self_link]

  backends = {
    cr-container-web = {
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
          group = google_compute_region_network_endpoint_group.cr-container-web.id
        },
        {
          group = google_compute_region_network_endpoint_group.cr-container-web-dr.id
        }
      ]

      iap_config = {
        enable = false
      }
    }
  cr-adminportal-web = {
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
        enable = true
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
          group = google_compute_region_network_endpoint_group.cr-adminportal-web.id
        },
        {
          group = google_compute_region_network_endpoint_group.cr-adminportal-web-dr.id
        }
      ]

      iap_config = {
        enable = false
      }
    }

  cr-app-crossdock = {
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
        enable = true
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
          group = google_compute_region_network_endpoint_group.cr-app-crossdock.id
        },
        {
          group = google_compute_region_network_endpoint_group.cr-app-crossdock-dr.id
        }
      ]

      iap_config = {
        enable = false
      }
    }
  }

  

  create_url_map = false
  url_map        = google_compute_url_map.url_map_qsight_dr[0].self_link

  http_forward   = false
  https_redirect = true

  load_balancing_scheme = "EXTERNAL"
}
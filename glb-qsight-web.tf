# Create a static IP address for the load balancer
resource "google_compute_global_address" "lb_qsight_web_ip" {
  name         = "static-lb-qsight-${var.name_project}-global-ip"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}

resource "google_compute_managed_ssl_certificate" "ssl_qsight_web" {
  name        = "sl-cert-${var.environment}-qsight-web-${var.project_name}"

  managed {
    domains = ["${var.environment}.web.qsight.net"]
  }
}

resource "google_compute_region_network_endpoint_group" "cr-container-web" {
  name                  = "neg-cr-container-web"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = "cr-web-mf-container-api-qsight-${var.environment}-${var.name_region}"
  }
}

resource "google_compute_region_network_endpoint_group" "cr-app-crossdock" {
  name                  = "neg-cr-app-crossdock"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = "cr-app-crossdock-qsight-${var.environment}-${var.name_region}"
  }
}

resource "google_compute_region_network_endpoint_group" "cr-web-mf-container" {
  name                  = "neg-cr-web-mf-container"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = "cr-web-mf-container-api-qsight-${var.environment}-${var.name_region}"
  }
}

resource "google_compute_region_network_endpoint_group" "cr-adminportal-web" {
  name                  = "neg-cr-adminportal-web"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = "cr-web-mf-adminportal-api-qsight-${var.environment}-${var.name_region}"
  }
}

resource "google_compute_url_map" "url_map_qsight_web" {
  count = var.is_dr_enabled ? 0 : 1
  name            = "glb-${var.name_project}-qsight-web"
  default_service = module.glb-qsight-web[0].backend_services["cr-web-mf-container"].self_link

  host_rule {
    hosts        = ["${var.environment}-qsight-web.qsight.net"]
    path_matcher = "qsight-paths"
  }

  path_matcher {
    name            = "qsight-paths"
    default_service = module.glb-qsight-web[0].backend_services["cr-web-mf-container"].self_link
    
    path_rule {
      paths   = ["/fulfillment", "/fulfillment/*"]
      service = module.glb-qsight-web[0].backend_services["cr-app-crossdock"].self_link
    }

    path_rule {
      paths   = ["/*"]
      service = module.glb-qsight-web[0].backend_services["cr-web-mf-container"].self_link
    }
    
    path_rule {
      paths   = ["/BarcodeSupport", "/BarcodeSupport/*"]
      service = module.glb-qsight-web[0].backend_services["cr-adminportal-web"].self_link
    }
  }
}

module "glb-qsight-web" {
  count = var.is_dr_enabled ? 0 : 1
  source            = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  version           = "12.0.0"
  project           = var.project_id
  name              = "glb-qsight-${var.environment}-web"
  address           = google_compute_global_address.lb_qsight_web_ip.address
  create_address    = false
  ssl               = true
  ssl_certificates = [google_compute_managed_ssl_certificate.ssl_qsight_web.self_link]
  https_redirect                  = true
  backends = {
    cr-app-crossdock = {
      protocol   = "HTTPS"
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
      groups = [
        {
          group = google_compute_region_network_endpoint_group.cr-app-crossdock.id
        }
      ]
      iap_config = {
        enable = false
      }
      log_config = {
        enable      = true
        sample_rate = 1.0
      }
    }
    cr-web-mf-container = {
      protocol   = "HTTPS"
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
      groups = [
        {
          group = google_compute_region_network_endpoint_group.cr-web-mf-container.id
        }
      ]
      iap_config = {
        enable = false
      }
      log_config = {
        enable      = true
        sample_rate = 1.0
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
      groups = [
        {
          group = google_compute_region_network_endpoint_group.cr-adminportal-web.id
        }
      ]

      iap_config = {
        enable = false
      }
    }
  }
  create_url_map = false
  url_map        = google_compute_url_map.url_map_qsight_web[0].self_link
  http_forward   = false
  load_balancing_scheme = "EXTERNAL_MANAGED"
}
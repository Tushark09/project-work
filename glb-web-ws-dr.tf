
module "lb-http-dr" {
  count = var.is_dr_enabled ? 1 : 0
  source  = "GoogleCloudPlatform/lb-http/google"
  version           = "12.0.0"

  project = var.project_id
  name    = "glb-${var.name_project}-web"  

  create_address    = false
  address           = google_compute_global_address.lb_web_ip.address
  ssl               = true
  ssl_certificates  = [google_compute_managed_ssl_certificate.ssl_web_ws.self_link, google_compute_managed_ssl_certificate.ssl_ipm.self_link]
  firewall_networks = []
  backends = {
    webserver = {
      protocol    = "HTTPS"
      port        = 443
      port_name   = "https"
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
    
      custom_request_headers  = null
      custom_response_headers = null

    

      connection_draining_timeout_sec = null
      session_affinity                = null
      affinity_cookie_ttl_sec         = null

      
      health_check = {
        check_interval_sec  = 5
        timeout_sec         = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
        protocol = "HTTP"
        request_path        = "/"
        port                = 80
        host                = "${var.environment}.qsight.net"
        logging             = null
      }

      log_config = {
        enable      = false
        sample_rate = null
      }

      groups = [
        for group in concat(local.umig_web_server_links, local.umig_web_server_dr_links) : {
          group           = group
          balancing_mode  = "UTILIZATION"
          max_utilization = 0.8
          capacity_scaler = 1.0
        }
      ]

      iap_config = {
        enable               = false
        oauth2_client_id     = null
        oauth2_client_secret = null
      }
    }

    ipm = {
      protocol    = "HTTPS"
      port        = 443
      port_name   = "https"
      timeout_sec = 120
      enable_cdn  = true
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
      cache_key_policy = {
        include_query_string = true
      }
      security_policy       = module.cloud-armor.policy.name
    
      custom_request_headers  = null
      custom_response_headers = null

    

      connection_draining_timeout_sec = null
      session_affinity                = null
      affinity_cookie_ttl_sec         = null

      
      health_check = {
        check_interval_sec  = 5
        timeout_sec         = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
        port                = 443
        host                = "${var.domain-ipm}"
        logging             = null
      }

      log_config = {
        enable      = false
        sample_rate = null
      }

      groups = [
        for group in concat(local.umig_web_server_links, local.umig_web_server_dr_links) : {
          group           = group
          balancing_mode  = "UTILIZATION"
          max_utilization = 0.8
          capacity_scaler = 1.0
        }
      ]

      iap_config = {
        enable               = false
        oauth2_client_id     = null
        oauth2_client_secret = null
      }
    }

    webservice = {
      protocol    = "HTTPS"
      port        = 443
      port_name   = "https"
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
    

      custom_request_headers  = null
      custom_response_headers = null

      security_policy       = module.cloud-armor.policy.name

      connection_draining_timeout_sec = null
      session_affinity                = null
      affinity_cookie_ttl_sec         = null
      
      health_check = {
        check_interval_sec  = 5
        timeout_sec         = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
        request_path        = "/status.html"
        port                = 443
        host                = "${var.environment}.qws.qsight.net"
        logging             = null
      }
       
      log_config = {
        enable      = false
        sample_rate = null
      }

      groups = [
        for group in concat(local.umig_web_service_links, local.umig_web_service_dr_links) : {
          group           = group
          balancing_mode  = "UTILIZATION"
          max_utilization = 0.8
          capacity_scaler = 1.0
        }
      ]

      iap_config = {
        enable               = false
        oauth2_client_id     = null
        oauth2_client_secret = null
      }
    }
  }

  create_url_map = false
  url_map        = google_compute_url_map.url_map_dr[0].self_link

  http_forward   = true
  https_redirect = true

  load_balancing_scheme = "EXTERNAL_MANAGED"
}


# Create a URL map to route requests to the appropriate backend
resource "google_compute_url_map" "url_map_dr" {
  count = var.is_dr_enabled ? 1 : 0
  name            = "glb-${var.name_project}-web"
  default_service = module.lb-http-dr[0].backend_services["webserver"].self_link

  host_rule {
    hosts        = ["${var.glb_web_ws_domain}", "${var.environment}.qsight.net"] 
    path_matcher = "web-server-paths"
  }

  host_rule {
    hosts        = ["${var.domain-ipm}"]
    path_matcher = "ipm-paths"
  }

  host_rule {
    hosts        = ["${var.environment}.iws.qsight.net", "${var.environment}.qws.qsight.net"]
    path_matcher = "web-service-paths"
  }

  path_matcher {
    name            = "web-server-paths"
    default_service = module.lb-http-dr[0].backend_services["webserver"].self_link
  }

  path_matcher {
    name            = "web-service-paths"
    default_service = module.lb-http-dr[0].backend_services["webservice"].self_link
  }

   path_matcher {
    name            = "ipm-paths"
    default_service = module.lb-http-dr[0].backend_services["ipm"].self_link
    path_rule {
      paths   = ["/*"]
      service = module.lb-http-dr[0].backend_services["ipm"].self_link
    }
  }
}
module "glb-qsight-iis-web-dr" {
  count = var.is_dr_enabled ? 1 : 0
  source  = "GoogleCloudPlatform/lb-http/google"
  version           = "12.0.0"
  project = var.project_id
  name    = "glb-${var.name_project}-${var.project_name}-iis-web"  

  create_address    = false
  address           = google_compute_global_address.lb_iis_web_ip.address
  ssl               = true
  firewall_networks = []
  ssl_certificates  = [google_compute_managed_ssl_certificate.ssl_iis_web.self_link]

  backends = {
      ws-parmobile-web = {
      protocol     = "HTTP"
      port         = 80
      port_name    = "http"
      timeout_sec  = 120  
      enable_cdn   = true 
      session_affinity = "GENERATED_COOKIE"
      affinity_cookie_ttl_sec = 10800
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
      custom_response_headers = [        "Access-Control-Allow-Origin: *",         "Access-Control-Allow-Headers: *", "Access-Control-Allow-Methods: *"]
      health_check = {
        check_interval_sec  = 5
        timeout_sec         = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
        request_path        = "/QparMgmt/UI/Login.aspx"
        host                = var.glb_qsight_iis_web_paramobile_domain
        port                = 80
        protocol            = "HTTP"
      }
      log_config = {
        enable      = false
        sample_rate = 1.0
      }
      groups = [
        for group in concat(local.umig_iis_web_server_links, local.umig_iis_web_server_dr_links) : {
          group           = group
          balancing_mode  = "UTILIZATION"
          max_utilization = 0.8
          capacity_scaler = 1.0
        }
      ]
      iap_config = {
        enable = false
      }
    }

    ws-qsightweb-web = {
      protocol     = "HTTP"
      port         = 80
      port_name    = "http"
      timeout_sec  = 120  
      enable_cdn   = true 
      session_affinity = "GENERATED_COOKIE"
      affinity_cookie_ttl_sec = 10800
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
      custom_response_headers = [        "Access-Control-Allow-Origin: *",         "Access-Control-Allow-Headers: *", "Access-Control-Allow-Methods: *"]
      health_check = {
        check_interval_sec  = 5
        timeout_sec         = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
        request_path        = "/"
        host                = var.glb_qsight_iis_web_webapp_domain
        port                = 80
        protocol            = "HTTP"
      }
      log_config = {
        enable      = false
        sample_rate = 1.0
      }
      groups = [
        for group in concat(local.umig_iis_web_server_links, local.umig_iis_web_server_dr_links) : {
          group           = group
          balancing_mode  = "UTILIZATION"
          max_utilization = 0.8
          capacity_scaler = 1.0
        }
      ]
      iap_config = {
        enable = false
      }
    }

    ws-qsightadmin-web = {
      protocol     = "HTTP"
      port         = 80
      port_name    = "http"
      timeout_sec  = 120  
      enable_cdn   = true 
      session_affinity = "GENERATED_COOKIE"
      affinity_cookie_ttl_sec = 10800
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
      custom_response_headers = [        "Access-Control-Allow-Origin: *",         "Access-Control-Allow-Headers: *", "Access-Control-Allow-Methods: *"]
      health_check = {
        check_interval_sec  = 5
        timeout_sec         = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
        request_path        = "/"
        host                = var.glb_qsight_iis_web_admin_domain
        port                = 80
        protocol            = "HTTP"
      }
      log_config = {
        enable      = false
        sample_rate = 1.0
      }
      groups = [
        for group in concat(local.umig_iis_web_server_links, local.umig_iis_web_server_dr_links) : {
          group           = group
          balancing_mode  = "UTILIZATION"
          max_utilization = 0.8
          capacity_scaler = 1.0
        }
      ]
      iap_config = {
        enable = false
      }
    }
    ws-qsightlanding-api = {
      protocol     = "HTTP"
      port         = 80
      port_name    = "http"
      timeout_sec  = 120  
      enable_cdn   = true 
      session_affinity = "GENERATED_COOKIE"
      affinity_cookie_ttl_sec = 10800
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
      custom_response_headers = [        "Access-Control-Allow-Origin: *",         "Access-Control-Allow-Headers: *", "Access-Control-Allow-Methods: *"]
      health_check = {
        check_interval_sec  = 5
        timeout_sec         = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
        request_path        = "/"
        host                = var.glb_qsight_iis_web_landingapi_domain
        port                = 80
        protocol            = "HTTP"
      }
      log_config = {
        enable      = false
        sample_rate = 1.0
      }
      groups = [
        for group in concat(local.umig_iis_web_server_links, local.umig_iis_web_server_dr_links) : {
          group           = group
          balancing_mode  = "UTILIZATION"
          max_utilization = 0.8
          capacity_scaler = 1.0
        }
      ]
      iap_config = {
        enable = false
      }
    }

    ws-qsightlogin-web = {
      protocol     = "HTTP"
      port         = 80
      port_name    = "http"
      timeout_sec  = 120  
      enable_cdn   = true 
      session_affinity = "GENERATED_COOKIE"
      affinity_cookie_ttl_sec = 10800
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
      custom_response_headers = [        "Access-Control-Allow-Origin: *",         "Access-Control-Allow-Headers: *", "Access-Control-Allow-Methods: *"]
      health_check = {
        check_interval_sec  = 5
        timeout_sec         = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
        request_path        = "/"
        host                = var.glb_qsight_iis_web_login_domain
        port                = 80
        protocol            = "HTTP"
      }
      log_config = {
        enable      = false
        sample_rate = 1.0
      }
      groups = [
        for group in concat(local.umig_iis_web_server_links, local.umig_iis_web_server_dr_links) : {
          group           = group
          balancing_mode  = "UTILIZATION"
          max_utilization = 0.8
          capacity_scaler = 1.0
        }
      ]
      iap_config = {
        enable = false
      }
    }
  }

  create_url_map = false
  url_map        = google_compute_url_map.glb-qsight-iis-web-dr[0].self_link

  http_forward   = true
  https_redirect = true

  load_balancing_scheme = "EXTERNAL_MANAGED"
}

# Create a URL map to route requests to the appropriate backend
resource "google_compute_url_map" "glb-qsight-iis-web-dr" {
  count = var.is_dr_enabled ? 1 : 0
  name            = "um-glb-${var.environment}-qsight-iis-web"
  default_service = module.glb-qsight-iis-web-dr[0].backend_services["ws-qsightlogin-web"].self_link

  host_rule {
    hosts        = [var.glb_qsight_iis_web_login_domain]
    path_matcher = "qsightlogin-web-paths"
  }

  host_rule {
    hosts        = [var.glb_qsight_iis_web_paramobile_domain]
    path_matcher = "parmobile-web-paths"
  }

  host_rule {
    hosts        = [var.glb_qsight_iis_web_webapp_domain,var.glb_qsight_iis_web_dashboard_domain]
    path_matcher = "qsightweb-web-paths"
  }

  host_rule {
    hosts        = [var.glb_qsight_iis_web_admin_domain]
    path_matcher = "qsightadmin-web-paths"
  }

  host_rule {
    hosts        = [var.glb_qsight_iis_web_landingapi_domain]
    path_matcher = "qsightlanding-api-paths"
  }

  path_matcher {
    name            = "qsightlogin-web-paths"
    default_service = module.glb-qsight-iis-web-dr[0].backend_services["ws-qsightlogin-web"].self_link
    
    path_rule {
      paths   = ["/*"]
      service = module.glb-qsight-iis-web-dr[0].backend_services["ws-qsightlogin-web"].self_link
    }
  }
  path_matcher {
    name            = "parmobile-web-paths"
    default_service = module.glb-qsight-iis-web-dr[0].backend_services["ws-parmobile-web"].self_link
    path_rule {
      paths   = ["/*"]
      service = module.glb-qsight-iis-web-dr[0].backend_services["ws-parmobile-web"].self_link
    }
  }
  path_matcher {
    name            = "qsightweb-web-paths"
    default_service = module.glb-qsight-iis-web-dr[0].backend_services["ws-qsightweb-web"].self_link
    path_rule {
      paths   = ["/*"]
      service = module.glb-qsight-iis-web-dr[0].backend_services["ws-qsightweb-web"].self_link
    }
  }
  path_matcher {
    name            = "qsightadmin-web-paths"
    default_service = module.glb-qsight-iis-web-dr[0].backend_services["ws-qsightadmin-web"].self_link
    path_rule {
      paths   = ["/*"]
      service = module.glb-qsight-iis-web-dr[0].backend_services["ws-qsightadmin-web"].self_link
    }
  }
  path_matcher {
    name            = "qsightlanding-api-paths"
    default_service = module.glb-qsight-iis-web-dr[0].backend_services["ws-qsightlanding-api"].self_link
    path_rule {
      paths   = ["/*"]
      service = module.glb-qsight-iis-web-dr[0].backend_services["ws-qsightlanding-api"].self_link
    } 
  }
}
resource "google_compute_url_map" "glb-qsight-api-dr" {
  count           = var.is_dr_enabled ? 1 : 0
  name            = "um-glb-qsight-${var.environment}-qsight-api"
  default_service = module.glb-qsight-api-dr[0].backend_services["qsightencounters-api"].self_link

  host_rule {
    hosts        = ["${var.environment}.api.qsight.net"]
    path_matcher = "qsight-api-paths"
  }

  path_matcher {
    name            = "qsight-api-paths"
    default_service = module.glb-qsight-api-dr[0].backend_services["qsightorders-api"].self_link
    path_rule {
      paths   = ["/api/v1/encounters/*"]
      service = module.glb-qsight-api-dr[0].backend_services["qsightencounters-api"].self_link
    }
    path_rule {
      paths   = ["/api/v1/orders/*"]
      service = module.glb-qsight-api-dr[0].backend_services["qsightorders-api"].self_link
    }
    path_rule {
      paths   = ["/api/case/*", "/api/omapps-common/*", "/api/return/*"]
      service = module.glb-qsight-api-dr[0].backend_services["casemgmt-api"].self_link
    }
    path_rule {
      paths   = ["/api/v1/product/*", "/api/v1/products/*"]
      service = module.glb-qsight-api-dr[0].backend_services["qsightproducts-api"].self_link
    }
    path_rule {
      paths   = ["/api/v1/alerts/*"]
      service = module.glb-qsight-api-dr[0].backend_services["qsightalerts-api"].self_link
    }
    path_rule {
      paths   = ["/api/v1/common/*"]
      service = module.glb-qsight-api-dr[0].backend_services["qsightcommon-api"].self_link
    }
    path_rule {
      paths   = ["/api/v1/inventory/*"]
      service = module.glb-qsight-api-dr[0].backend_services["qsightinventory-api"].self_link
    }
    path_rule {
      paths   = ["/api/v1/user/*", "/api/v1/users/*"]
      service = module.glb-qsight-api-dr[0].backend_services["qsightusers-api"].self_link
    }
    path_rule {
      paths   = ["/api/realtime-usage-dispatcher"]
      service = module.glb-qsight-api-dr[0].backend_services["usage-function"].self_link
    }
    path_rule {
      paths   = ["/api/v1/rediscache/*"]
      service = module.glb-qsight-api-dr[0].backend_services["rediscachemanager-function"].self_link
    }
    path_rule {
      paths   = ["/api/v1/function/sqljobs/*"]
      service = module.glb-qsight-api-dr[0].backend_services["sqljobs-function"].self_link
    }
    path_rule {
      paths   = ["/api/v1/barcode/*"]
      service = module.glb-qsight-api-dr[0].backend_services["barcode-function"].self_link
    }
    path_rule {
      paths   = ["/api/v2/authentication/*"]
      service = module.glb-qsight-api-dr[0].backend_services["authentication-function"].self_link
    }
    path_rule {
      paths   = ["/api/v1/itemMasterExceptions/*"]
      service = module.glb-qsight-api-dr[0].backend_services["ime-function"].self_link
    }
    path_rule {
      paths   = ["/api/v2/product/*"]
      service = module.glb-qsight-api-dr[0].backend_services["product-function"].self_link
    }
    path_rule {
      paths   = ["/api/v1/KnowledgeCenter/*"]
      service = module.glb-qsight-api-dr[0].backend_services["knowledgecenter-function"].self_link
    }
    path_rule {
      paths   = ["/api/v1/zendesk/*"]
      service = module.glb-qsight-api-dr[0].backend_services["zendesk-api"].self_link
    }
    path_rule {
      paths   = ["/api/v1/rfid/*"]
      service = module.glb-qsight-api-dr[0].backend_services["qsightrfid-api"].self_link
    }
    path_rule {
      paths   = ["/api/v2/encounter/*", "/api/v2/encounters/*", "/api/v2/tissuecardreturn/*"]
      service = module.glb-qsight-api-dr[0].backend_services["encounter-function"].self_link
    }
    path_rule {
      paths   = ["/api/v1/kanban/*"]
      service = module.glb-qsight-api-dr[0].backend_services["kanban-api"].self_link
    }
    path_rule {
      paths   = ["/api/v1/qmenu/*"]
      service = module.glb-qsight-api-dr[0].backend_services["qmenu-api"].self_link
    }
    
    path_rule {
      paths   = ["/api/b2b/*"]
      service = module.glb-qsight-api-dr[0].backend_services_hc["ws-qsightauth-api"].self_link
    }
    path_rule {
      paths   = ["/api/security/*"]
      service = module.glb-qsight-api-dr[0].backend_services_hc["ws-qsightsecurity-api"].self_link
    }
    path_rule {
      paths   = ["/adminapi/*"]
      service = module.glb-qsight-api-dr[0].backend_services_hc["ws-qsightadmin-api"].self_link
    }
  }
}


resource "google_compute_region_network_endpoint_group" "cr-qsightencounters-api-dr" {
  name                  = "neg-cr-qsightencounters-api-dr"
  network_endpoint_type = "SERVERLESS"
  region                = var.dr_region
  cloud_run {
    service = "cr-qsightencounters-api-qsight-${var.environment}-${var.name_region_dr}"
  }
}

resource "google_compute_region_network_endpoint_group" "cr-qsightorders-api-dr" {
  name                  = "neg-cr-qsightorders-api-dr"
  network_endpoint_type = "SERVERLESS"
  region                = var.dr_region
  cloud_run {
    service = "cr-qsightorders-api-qsight-${var.environment}-${var.name_region_dr}"
  }
}

resource "google_compute_region_network_endpoint_group" "cr-casemgmt-api-dr" {
  name                  = "neg-cr-casemgmt-api-dr"
  network_endpoint_type = "SERVERLESS"
  region                = var.dr_region
  cloud_run {
    service = "cr-casemgmt-api-qsight-${var.environment}-${var.name_region_dr}"
  }
}

resource "google_compute_region_network_endpoint_group" "cr-qsightproducts-api-dr" {
  name                  = "neg-cr-qsightproducts-api-dr"
  network_endpoint_type = "SERVERLESS"
  region                = var.dr_region
  cloud_run {
    service = "cr-qsightproducts-api-qsight-${var.environment}-${var.name_region_dr}"
  }
}

resource "google_compute_region_network_endpoint_group" "cr-qsightalerts-api-dr" {
  name                  = "neg-cr-qsightalerts-api-dr"
  network_endpoint_type = "SERVERLESS"
  region                = var.dr_region
  cloud_run {
    service = "cr-qsightalerts-api-qsight-${var.environment}-${var.name_region_dr}"
  }
}

resource "google_compute_region_network_endpoint_group" "cr-qsightcommon-api-dr" {
  name                  = "neg-cr-qsightcommon-api-dr"
  network_endpoint_type = "SERVERLESS"
  region                = var.dr_region
  cloud_run {
    service = "cr-qsightcommon-api-qsight-${var.environment}-${var.name_region_dr}"
  }
}

resource "google_compute_region_network_endpoint_group" "cr-qsightinventory-api-dr" {
  name                  = "neg-cr-qsightinventory-api-dr"
  network_endpoint_type = "SERVERLESS"
  region                = var.dr_region
  cloud_run {
    service = "cr-qsightinventory-api-qsight-${var.environment}-${var.name_region_dr}"
  }
}

resource "google_compute_region_network_endpoint_group" "cr-qsightusers-api-dr" {
  name                  = "neg-cr-qsightusers-api-dr"
  network_endpoint_type = "SERVERLESS"
  region                = var.dr_region
  cloud_run {
    service = "cr-qsightusers-api-qsight-${var.environment}-${var.name_region_dr}"
  }
}

resource "google_compute_region_network_endpoint_group" "cr-usage-function-dr" {
  name                  = "neg-cr-usage-function-dr"
  network_endpoint_type = "SERVERLESS"
  region                = var.dr_region
  cloud_run {
    service = "cr-usage-function-qsight-${var.environment}-${var.name_region_dr}"
  }
}

resource "google_compute_region_network_endpoint_group" "cr-rediscachemanager-function-dr" {
  name                  = "neg-cr-rediscachemanager-function-dr"
  network_endpoint_type = "SERVERLESS"
  region                = var.dr_region
  cloud_run {
    service = "cr-rediscachemanager-function-qsight-${var.environment}-${var.name_region_dr}"
  }
}

resource "google_compute_region_network_endpoint_group" "cr-sqljobs-function-dr" {
  name                  = "neg-cr-sqljobs-function-dr"
  network_endpoint_type = "SERVERLESS"
  region                = var.dr_region
  cloud_run {
    service = "cr-sqljobs-function-qsight-${var.environment}-${var.name_region_dr}"
  }
}

resource "google_compute_region_network_endpoint_group" "cr-barcode-function-dr" {
  name                  = "neg-cr-barcode-function-dr"
  network_endpoint_type = "SERVERLESS"
  region                = var.dr_region
  cloud_run {
    service = "cr-barcode-function-qsight-${var.environment}-${var.name_region_dr}"
  }
}

resource "google_compute_region_network_endpoint_group" "cr-authentication-function-dr" {
  name                  = "neg-cr-authentication-function-dr"
  network_endpoint_type = "SERVERLESS"
  region                = var.dr_region
  cloud_run {
    service = "cr-authentication-function-qsight-${var.environment}-${var.name_region_dr}"
  }
}

resource "google_compute_region_network_endpoint_group" "cr-ime-function-dr" {
  name                  = "neg-cr-ime-function-dr"
  network_endpoint_type = "SERVERLESS"
  region                = var.dr_region
  cloud_run {
    service = "cr-ime-function-qsight-${var.environment}-${var.name_region_dr}"
  }
}

resource "google_compute_region_network_endpoint_group" "cr-product-function-dr" {
  name                  = "neg-cr-product-function-dr"
  network_endpoint_type = "SERVERLESS"
  region                = var.dr_region
  cloud_run {
    service = "cr-product-function-qsight-${var.environment}-${var.name_region_dr}"
  }
}

resource "google_compute_region_network_endpoint_group" "cr-knowledgecenter-function-dr" {
  name                  = "neg-cr-knowledgecenter-function-dr"
  network_endpoint_type = "SERVERLESS"
  region                = var.dr_region
  cloud_run {
    service = "cr-knowledgecenter-function-qsight-${var.environment}-${var.name_region_dr}"
  }
}

resource "google_compute_region_network_endpoint_group" "cr-zendesk-api-dr" {
  name                  = "neg-cr-zendesk-api-dr"
  network_endpoint_type = "SERVERLESS"
  region                = var.dr_region
  cloud_run {
    service = "cr-zendesk-api-qsight-${var.environment}-${var.name_region_dr}"
  }
}

resource "google_compute_region_network_endpoint_group" "cr-qsightrfid-api-dr" {
  name                  = "neg-cr-qsightrfid-api-dr"
  network_endpoint_type = "SERVERLESS"
  region                = var.dr_region
  cloud_run {
    service = "cr-qsightrfid-api-qsight-${var.environment}-${var.name_region_dr}"
  }
}

resource "google_compute_region_network_endpoint_group" "cr-kanban-api-dr" {
  name                  = "neg-cr-kanban-api-dr"
  network_endpoint_type = "SERVERLESS"
  region                = var.dr_region
  cloud_run {
    service = "cr-kanban-api-qsight-${var.environment}-${var.name_region_dr}"
  }
}

resource "google_compute_region_network_endpoint_group" "cr-qmenu-api-dr" {
  name                  = "neg-cr-qmenu-api-dr"
  network_endpoint_type = "SERVERLESS"
  region                = var.dr_region
  cloud_run {
    service = "cr-qmenu-api-qsight-${var.environment}-${var.name_region_dr}"
  }
}


resource "google_compute_region_network_endpoint_group" "cr-encounter-function-dr" {
  name                  = "neg-cr-encounter-function-dr"
  network_endpoint_type = "SERVERLESS"
  region                = var.dr_region
  cloud_run {
    service = "cr-encounter-function-qsight-${var.environment}-${var.name_region_dr}"
  }
}

module "glb-qsight-api-dr" {
  count             = var.is_dr_enabled ? 1 : 0
  source            = "./modules/serverless_negs"
  project           = var.project_id
  name              = "glb-qsight-${var.environment}-qsight-api"
  address           = google_compute_global_address.glb-qsight-api.address
  create_address    = false
  ssl               = true
  ssl_certificates = [google_compute_managed_ssl_certificate.ssl_qsight_api.self_link]
  https_redirect                  = true
  backends_hc = {
    
    ws-qsightauth-api = {
      protocol     = "HTTP"
      port         = 85
      port_name    = "http-85"
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
      security_policy = module.cloud-armor.policy.name
      health_check = {
        check_interval_sec  = 5
        timeout_sec         = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
        request_path        = "/"
        port                = 85
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

    ws-qsightsecurity-api = {
      protocol     = "HTTP"
      port         = 81
      port_name    = "http-81"
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
      security_policy = module.cloud-armor.policy.name
      health_check = {
        check_interval_sec  = 5
        timeout_sec         = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
        request_path        = "/"
        port                = 81
        protocol            = "HTTP"
      }
      log_config = {
        enable      = true
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

    ws-qsightadmin-api = {
      protocol     = "HTTP"
      port         = 86
      port_name    = "http-86"
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
      security_policy = module.cloud-armor.policy.name
      health_check = {
        check_interval_sec  = 5
        timeout_sec         = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
        request_path        = "/"
        port                = 86
        protocol            = "HTTP"
      }
      log_config = {
        enable      = true
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
  backends = {
    
    qsightencounters-api = {
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
      security_policy                 = module.cloud-armor.policy.name
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
      log_config = {
        enable = true
        sample_rate = 1.0
      }
      groups = [
        {
          group = google_compute_region_network_endpoint_group.cr-qsightencounters-api.id
        },

        {
          group = google_compute_region_network_endpoint_group.cr-qsightencounters-api-dr.id
        }
      ]

      iap_config = {
        enable = false
      }
    }

    qmenu-api = {
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
      security_policy                 = module.cloud-armor.policy.name
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
      log_config = {
        enable = true
        sample_rate = 1.0
      }
      groups = [
        {
          group = google_compute_region_network_endpoint_group.cr-qmenu-api.id
        },
        {
          group = google_compute_region_network_endpoint_group.cr-qmenu-api-dr.id
        }

      ]

      iap_config = {
        enable = false
      }
    }

    qsightorders-api = {
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
      security_policy                 = module.cloud-armor.policy.name
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
      log_config = {
        enable = true
        sample_rate = 1.0
      }
      groups = [
        {
          group = google_compute_region_network_endpoint_group.cr-qsightorders-api.id
        },
        {
          group = google_compute_region_network_endpoint_group.cr-qsightorders-api-dr.id
        }
        
      ]

      iap_config = {
        enable = false
      }
    }

    kanban-api = {
      protocol            = "HTTPS"
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
      security_policy     = module.cloud-armor.policy.name
      log_config = {
        enable = true
        sample_rate = 1.0
      }
      groups = [
        {
          group = google_compute_region_network_endpoint_group.cr-kanban-api.id
        },
        {
          group = google_compute_region_network_endpoint_group.cr-kanban-api-dr.id
        }
      ]
      iap_config = {
        enable = false
      }
    }      

    casemgmt-api = {
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
      security_policy                 = module.cloud-armor.policy.name
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
      log_config = {
        enable = true
        sample_rate = 1.0
      }
      groups = [
        {
          group = google_compute_region_network_endpoint_group.cr-casemgmt-api.id
        },
        {
          group = google_compute_region_network_endpoint_group.cr-casemgmt-api-dr.id
        }

      ]

      iap_config = {
        enable = false
      }
    }

    qsightproducts-api = {
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
      security_policy                 = module.cloud-armor.policy.name
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
      log_config = {
        enable = true
        sample_rate = 1.0
      }
      groups = [
        {
          group = google_compute_region_network_endpoint_group.cr-qsightproducts-api.id
        },
        {
          group = google_compute_region_network_endpoint_group.cr-qsightproducts-api-dr.id
        }

      ]

      iap_config = {
        enable = false
      }
    }

    qsightalerts-api = {
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
      security_policy                 = module.cloud-armor.policy.name
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
      log_config = {
        enable = true
        sample_rate = 1.0
      }
      groups = [
        {
          group = google_compute_region_network_endpoint_group.cr-qsightalerts-api.id
        }
      ]

      iap_config = {
        enable = false
      }
    }

    qsightcommon-api = {
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
      security_policy                 = module.cloud-armor.policy.name
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
      log_config = {
        enable = true
        sample_rate = 1.0
      }
      groups = [
        {
          group = google_compute_region_network_endpoint_group.cr-qsightcommon-api.id
        },
        {
          group = google_compute_region_network_endpoint_group.cr-qsightcommon-api-dr.id
        },

      ]

      iap_config = {
        enable = false
      }
    }

    qsightinventory-api = {
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
      security_policy                 = module.cloud-armor.policy.name
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
      log_config = {
        enable = true
        sample_rate = 1.0
      }
      groups = [
        {
          group = google_compute_region_network_endpoint_group.cr-qsightinventory-api.id
        },
        {
          group = google_compute_region_network_endpoint_group.cr-qsightinventory-api-dr.id
        },

      ]

      iap_config = {
        enable = false
      }
    }

    qsightusers-api = {
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
      security_policy                 = module.cloud-armor.policy.name
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
      log_config = {
        enable = true
        sample_rate = 1.0
      }
      groups = [
        {
          group = google_compute_region_network_endpoint_group.cr-qsightusers-api.id
        },
        {
          group = google_compute_region_network_endpoint_group.cr-qsightusers-api-dr.id
        }
      ]

      iap_config = {
        enable = false
      }
    }

    usage-function = {
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
      security_policy                 = module.cloud-armor.policy.name
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
      custom_response_headers = [        "Access-Control-Allow-Origin: *",         "Access-Control-Allow-Headers: *",    "Access-Control-Allow-Methods: *"      ]
      log_config = {
        enable = true
        sample_rate = 1.0
      }
      groups = [
        {
          group = google_compute_region_network_endpoint_group.cr-usage-function.id
        },
        {
          group = google_compute_region_network_endpoint_group.cr-usage-function-dr.id
        }
      ]

      iap_config = {
        enable = false
      }
    }

    rediscachemanager-function = {
      protocol                        = "HTTPS"
      enable_cdn                      = false
      security_policy                 = module.cloud-armor.policy.name
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
      custom_response_headers = [        "Access-Control-Allow-Origin: *",         "Access-Control-Allow-Headers: *",    "Access-Control-Allow-Methods: *"      ]
      log_config = {
        enable = true
        sample_rate = 1.0
      }
      groups = [
        {
          group = google_compute_region_network_endpoint_group.cr-rediscachemanager-function.id
        }
      ]

      iap_config = {
        enable = false
      }
    }

    sqljobs-function = {
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
      security_policy                 = module.cloud-armor.policy.name
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
      custom_response_headers = [        "Access-Control-Allow-Origin: *",         "Access-Control-Allow-Headers: *",    "Access-Control-Allow-Methods: *"      ]
      log_config = {
        enable = true
        sample_rate = 1.0
      }
      groups = [
        {
          group = google_compute_region_network_endpoint_group.cr-sqljobs-function.id
        },
        {
          group = google_compute_region_network_endpoint_group.cr-sqljobs-function-dr.id
        }
      ]

      iap_config = {
        enable = false
      }
    }

    barcode-function = {
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
      security_policy                 = module.cloud-armor.policy.name
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
      custom_response_headers = [        "Access-Control-Allow-Origin: *",         "Access-Control-Allow-Headers: *",    "Access-Control-Allow-Methods: *"      ]
      log_config = {
        enable = true
        sample_rate = 1.0
      }
      groups = [
        {
          group = google_compute_region_network_endpoint_group.cr-barcode-function.id
        },
        {
          group = google_compute_region_network_endpoint_group.cr-barcode-function-dr.id
        }
      ]

      iap_config = {
        enable = false
      }
    }

    authentication-function = {
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
      security_policy                 = module.cloud-armor.policy.name
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
      custom_response_headers = [        "Access-Control-Allow-Origin: *",         "Access-Control-Allow-Headers: *",    "Access-Control-Allow-Methods: *"      ]
      log_config = {
        enable = true
        sample_rate = 1.0
      }
      groups = [
        {
          group = google_compute_region_network_endpoint_group.cr-authentication-function.id
        },
        {
          group = google_compute_region_network_endpoint_group.cr-authentication-function-dr.id
        }
      ]

      iap_config = {
        enable = false
      }
    }

    ime-function = {
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
      security_policy                 = module.cloud-armor.policy.name
      custom_response_headers = [        "Access-Control-Allow-Origin: *",         "Access-Control-Allow-Headers: *",    "Access-Control-Allow-Methods: *"      ]
      log_config = {
        enable = true
        sample_rate = 1.0
      }
      groups = [
        {
          group = google_compute_region_network_endpoint_group.cr-ime-function.id
        },
        {
          group = google_compute_region_network_endpoint_group.cr-ime-function-dr.id
        }
      ]

      iap_config = {
        enable = false
      }

      outlier_detection = {
        base_ejection_time = {
          seconds = 120
        }
        consecutive_errors                = 5
        consecutive_gateway_failure       = 3
        enforcing_consecutive_errors      = 100
        enforcing_consecutive_gateway_failure = 100
        enforcing_success_rate = null
        interval = {
          seconds = 10
        }
        max_ejection_percent              = 50
      }
    }

    product-function = {
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
      security_policy                 = module.cloud-armor.policy.name
      custom_response_headers = [        "Access-Control-Allow-Origin: *",         "Access-Control-Allow-Headers: *",    "Access-Control-Allow-Methods: *"      ]
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
          group = google_compute_region_network_endpoint_group.cr-product-function.id
        },
        {
          group = google_compute_region_network_endpoint_group.cr-product-function-dr.id
        }
      ]

      iap_config = {
        enable = false
      }
    }

    knowledgecenter-function = {
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
      security_policy                 = module.cloud-armor.policy.name
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
      custom_response_headers = [        "Access-Control-Allow-Origin: *",         "Access-Control-Allow-Headers: *",    "Access-Control-Allow-Methods: *"      ]
      log_config = {
        enable = true
        sample_rate = 1.0
      }
      groups = [
        {
          group = google_compute_region_network_endpoint_group.cr-knowledgecenter-function.id
        },
        {
          group = google_compute_region_network_endpoint_group.cr-knowledgecenter-function-dr.id
        }
      ]

      iap_config = {
        enable = false
      }
    }

    zendesk-api = {
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
      security_policy                 = module.cloud-armor.policy.name
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
      log_config = {
        enable = true
        sample_rate = 1.0
      }
      groups = [
        {
          group = google_compute_region_network_endpoint_group.cr-zendesk-api.id
        },
        {
          group = google_compute_region_network_endpoint_group.cr-zendesk-api-dr.id
        }
      ]

      iap_config = {
        enable = false
      }
    }

    qsightrfid-api = {
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
      security_policy                 = module.cloud-armor.policy.name
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
      log_config = {
        enable = true
        sample_rate = 1.0
      }
      groups = [
        {
          group = google_compute_region_network_endpoint_group.cr-qsightrfid-api.id
        }
      ]

      iap_config = {
        enable = false
      }
    }

    encounter-function = {
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
      security_policy                 = module.cloud-armor.policy.name
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
      custom_response_headers = [        "Access-Control-Allow-Origin: *",         "Access-Control-Allow-Headers: *",    "Access-Control-Allow-Methods: *"      ]
      log_config = {
        enable = true
        sample_rate = 1.0
      }
      groups = [
        {
          group = google_compute_region_network_endpoint_group.cr-encounter-function.id
        },
        {
          group = google_compute_region_network_endpoint_group.cr-encounter-function-dr.id
        }
      ]

      iap_config = {
        enable = false
      }
    }

  }
  
  create_url_map = false
  url_map        = google_compute_url_map.glb-qsight-api-dr[0].self_link
  load_balancing_scheme = "EXTERNAL_MANAGED"
}
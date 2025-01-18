resource "google_compute_address" "internal_static_ip_wsfc_internal_lb" {
  count        = var.is_fci_enabled ? 1 : 0
  name         = "static-ip-wsfc-internal-lb-${var.name_project}-${var.name_region}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_database_usc1
  address_type = "INTERNAL"
  region       = var.region
  project      = var.project_id
}

module "ilb-sql-wsfc" {
  count         = var.is_fci_enabled ? 1 : 0  
  source        = "./modules/net-lb-int"
  project_id    = var.project_id
  region        = var.region
  name          = "ilb-${var.name_project}-sql-wsfc"
  vpc_config = {
    network    = var.network
    subnetwork = var.subnet_database_usc1
  }
  backends = [
    for group in local.umig_sql_wsfc_nodes_links : {
        group  = group
    }
  ]
  health_check_config = {
    enable_logging = true
    tcp = {
      port = 59997
      healthy_threshold = 1
      unhealthy_threshold = 2
      timeout_sec = 1
    }
  }
  forwarding_rules_config = {
    "vip-one" = {
        address = google_compute_address.internal_static_ip_wsfc_internal_lb[0].address
        ports = ["1433", "5022"]
    }
  }
}

resource "google_compute_address" "internal_static_ip_wsfc_internal_lb_primary" {
  count        = var.is_fci_enabled ? 1 : 0
  name         = "static-ip-wsfc-pr-internal-lb-${var.name_project}-${var.name_region}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_database_usc1
  address_type = "INTERNAL"
  region       = var.region
  project      = var.project_id
}

module "ilb-sql-wsfc-primary" {
  count         = var.is_fci_enabled ? 1 : 0  
  source        = "./modules/net-lb-int"
  project_id    = var.project_id
  region        = var.region
  name          = "ilb-${var.name_project}-sql-wsfc-pr"
  vpc_config = {
    network    = var.network
    subnetwork = var.subnet_database_usc1
  }
  backends = [
    for group in local.umig_sql_wsfc_pr_nodes_links : {
        group  = group
    }
  ]
  health_check_config = {
    enable_logging = true
    tcp = {
      port = 59997
      healthy_threshold = 1
      unhealthy_threshold = 2
      timeout_sec = 1
    }
  }
  forwarding_rules_config = {
    "vip-one" = {
        address = google_compute_address.internal_static_ip_wsfc_internal_lb_primary[0].address
        ports = ["1433", "5022"]
    }
  }
}

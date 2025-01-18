resource "google_compute_address" "internal_static_ip_wsfc_internal_lb_dr" {
  count        = var.is_fci_enabled && var.is_dr_enabled ? 1 : 0
  name         = "static-ip-wsfc-internal-lb-${var.name_project}-${var.dr_region}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_database_dr
  address_type = "INTERNAL"
  region       = var.dr_region
  project      = var.project_id
}

# DR region internal load balancer for SQL WSFC
module "ilb-sql-wsfc-dr" {
  count         = var.is_fci_enabled && var.is_dr_enabled ? 1 : 0  
  source        = "./modules/net-lb-int"
  project_id    = var.project_id
  region        = var.dr_region
  name          = "ilb-${var.name_project}-sql-wsfc-dr"
  vpc_config = {
    network    = var.network
    subnetwork = var.subnet_database_dr
  }
  backends = [
    for group in local.umig_sql_wsfc_nodes_dr_links : { 
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
        address = google_compute_address.internal_static_ip_wsfc_internal_lb_dr[0].address
        ports = ["1433", "5022"]
    }
  }
}
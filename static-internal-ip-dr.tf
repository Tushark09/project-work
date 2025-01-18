# Create static internal IP addresses for each VM type in DR region
resource "google_compute_address" "internal_static_ip_int_dr" {
  count = var.num_instances_int_dr 
  name         = "static-ip-int-dr-${var.name_project}-${var.name_region_dr}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_web_dr
  address_type = "INTERNAL"
  region       = var.dr_region
  project      = var.project_id
}

resource "google_compute_address" "internal_static_ip_int_sql_dr" {
  count = var.num_instances_int_sql_dr 
  name         = "static-ip-int-sql-dr-${var.name_project}-${var.name_region_dr}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_database_dr
  address_type = "INTERNAL"
  region       = var.dr_region
  project      = var.project_id
}



resource "google_compute_address" "internal_static_ip_int_db_dr" {
  count = var.num_instances_int_sql_dr 
  name         = "static-ip-int-db-dr-${var.name_project}-${var.name_region_dr}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_database_dr
  address_type = "INTERNAL"
  region       = var.dr_region
  project      = var.project_id
}

resource "google_compute_address" "internal_static_ip_sql_dr" {
  count = var.num_instances_sql_dr 
  name         = "static-ip-sql-dr-${var.name_project}-${var.name_region_dr}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_database_dr
  address_type = "INTERNAL"
  region       = var.dr_region
  project      = var.project_id
}

resource "google_compute_address" "internal_static_ip_ws_dr" {
  count = var.num_instances_ws_dr 
  name         = "static-ip-ws-dr-${var.name_project}-${var.name_region_dr}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_web_dr
  address_type = "INTERNAL"
  region       = var.dr_region
  project      = var.project_id
}

resource "google_compute_address" "internal_static_ip_web_dr" {
  count = var.num_instances_web_dr 
  name         = "static-ip-web-dr-${var.name_project}-${var.name_region_dr}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_web_dr
  address_type = "INTERNAL"
  region       = var.dr_region
  project      = var.project_id
}

resource "google_compute_address" "internal_static_ip_iis_web_dr" {
  count = var.num_instances_iis_web_dr 
  name         = "static-ip-iis-web-dr-${var.name_project}-${var.name_region_dr}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_web_dr
  address_type = "INTERNAL"
  region       = var.dr_region
  project      = var.project_id
}

resource "google_compute_address" "internal_static_ip_report_sql_dr" {
  count = var.num_instances_report_sql_dr 
  name         = "static-ip-report-sql-dr-${var.name_project}-${var.name_region_dr}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_database_dr
  address_type = "INTERNAL"
  region       = var.dr_region
  project      = var.project_id
}

resource "google_compute_address" "internal_static_ip_activegate_dr" {
  count = var.num_instances_activegate_dr 
  name         = "static-ip-activegate-dr-${var.name_project}-${var.name_region_dr}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_web_dr
  address_type = "INTERNAL"
  region       = var.dr_region
  project      = var.project_id
}

resource "google_compute_address" "internal_static_ip_adf_dr" {
  count = var.num_instances_adf_dr 
  name         = "static-ip-adf-dr-${var.name_project}-${var.name_region_dr}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_web_dr
  address_type = "INTERNAL"
  region       = var.dr_region
  project      = var.project_id
}

resource "google_compute_address" "internal_static_ip_pbi_gateway_dr" {
  count = var.num_instances_pbi_gateway_dr 
  name         = "static-ip-pbi-gateway-dr-${var.name_project}-${var.name_region_dr}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_web_dr
  address_type = "INTERNAL"
  region       = var.dr_region
  project      = var.project_id
}

# Static IP for SQL WSFC Nodes DR
resource "google_compute_address" "internal_static_ip_sql_wsfc_node_dr" {
  count        = var.is_fci_enabled && var.is_dr_enabled ? 2 : 0  # 2 nodes
  name         = "static-ip-sql-wsfc-node-${var.name_project}-${var.name_region_dr}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_database_dr
  address_type = "INTERNAL"
  region       = var.dr_region
  project      = var.project_id
}

# Static IP for SQL WSFC Witness DR
resource "google_compute_address" "internal_static_ip_sql_wsfc_witness_dr" {
  count        = var.is_fci_enabled && var.is_dr_enabled ? 1 : 0
  name         = "static-ip-sql-wsfc-witness-${var.name_project}-${var.name_region_dr}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_database_dr
  address_type = "INTERNAL"
  region       = var.dr_region
  project      = var.project_id
}

# Static IP for WSFC Cluster DR
resource "google_compute_address" "internal_static_ip_wsfc_cluster_dr" {
  count        = var.is_fci_enabled && var.is_dr_enabled ? 1 : 0
  name         = "static-ip-wsfc-cluster-${var.name_project}-${var.name_region_dr}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_database_dr
  address_type = "INTERNAL"
  region       = var.dr_region
  project      = var.project_id
}


resource "google_compute_address" "internal_static_ip_pbi_sql_dr" {
  count        = var.num_instances_report_sql
  name         = "static-ip-pbi-sql-dr-${var.name_project}-${var.name_region_dr}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_database_dr
  address_type = "INTERNAL"
  region       = var.dr_region
  project      = var.project_id
}

resource "google_compute_address" "internal_static_ip_sql_mirror_witness_dr" {
  count        = var.is_fci_enabled && var.is_dr_enabled ? 1 : 0
  name         = "static-ip-sql-mirror-witness-${var.name_project}-${var.name_region_dr}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_database_dr
  address_type = "INTERNAL"
  region       = var.dr_region
  project      = var.project_id
}
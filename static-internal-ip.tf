# Create static internal IP addresses for each VM type
resource "google_compute_address" "internal_static_ip_int" {

  count        = var.num_instances_int
  name         = "static-ip-int-${var.name_project}-${var.name_region}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_web_usc1
  address_type = "INTERNAL"
  region       = var.region
  project      = var.project_id
}

resource "google_compute_address" "internal_static_ip_int_sql" {
  count        = var.num_instances_int_sql
  name         = "static-ip-int-sql-${var.name_project}-${var.name_region}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_database_usc1
  address_type = "INTERNAL"
  region       = var.region
  project      = var.project_id
}

resource "google_compute_address" "internal_static_ip_int_db" {
  count        = var.num_instances_int_db
  name         = "static-ip-int-db-${var.name_project}-${var.name_region}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_database_usc1
  address_type = "INTERNAL"
  region       = var.region
  project      = var.project_id
}

resource "google_compute_address" "internal_static_ip_ws" {
  count        = var.num_instances_ws
  name         = "static-ip-ws-${var.name_project}-${var.name_region}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_web_usc1
  address_type = "INTERNAL"
  region       = var.region
  project      = var.project_id
}

resource "google_compute_address" "internal_static_ip_web" {
  count        = var.num_instances_web

  name         = "static-ip-web-${var.name_project}-${var.name_region}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_web_usc1
  address_type = "INTERNAL"
  region       = var.region
  project      = var.project_id
}
resource "google_compute_address" "internal_static_ip_iis_web" {
  count        = var.num_instances_iis_web
  name         = "static-ip-iis-web-${var.name_project}-${var.name_region}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_web_usc1
  address_type = "INTERNAL"
  region       = var.region
  project      = var.project_id
}

resource "google_compute_address" "internal_static_ip_report_sql" {
  count        = var.num_instances_report_sql
  name         = "static-ip-report-sql-${var.name_project}-${var.name_region}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_database_usc1
  address_type = "INTERNAL"
  region       = var.region
  project      = var.project_id
}

resource "google_compute_address" "internal_static_ip_activegate" {

  count        = var.num_instances_activegate
  name         = "static-ip-activegate-${var.name_project}-${var.name_region}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_web_usc1
  address_type = "INTERNAL"
  region       = var.region
  project      = var.project_id
}

resource "google_compute_address" "internal_static_ip_adf" {
  count        = var.num_instances_adf
  name         = "static-ip-adf-${var.name_project}-${var.name_region}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_web_usc1
  address_type = "INTERNAL"
  region       = var.region
  project      = var.project_id
}

resource "google_compute_address" "internal_static_ip_pbi_gateway" {
  count        = var.num_instances_pbi_gateway
  name         = "static-ip-pbi-gateway-${var.name_project}-${var.name_region}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_web_usc1
  address_type = "INTERNAL"
  region       = var.region
  project      = var.project_id
}

resource "google_compute_address" "internal_static_ip_sql_wsfc_node" {
  count        = var.is_fci_enabled ? 2 : 0
  name         = "static-ip-sql-wsfc-node-${var.name_project}-${var.name_region}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_database_usc1
  address_type = "INTERNAL"
  region       = var.region
  project      = var.project_id
}

resource "google_compute_address" "internal_static_ip_sql_wsfc_witness" {
  count        = var.is_fci_enabled ? 1 : 0
  name         = "static-ip-sql-wsfc-witness-${var.name_project}-${var.name_region}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_database_usc1
  address_type = "INTERNAL"
  region       = var.region
  project      = var.project_id
}

resource "google_compute_address" "internal_static_ip_wsfc_cluster" {
  count        = var.is_fci_enabled ? 1 : 0
  name         = "static-ip-wsfc-cluster-${var.name_project}-${var.name_region}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_database_usc1
  address_type = "INTERNAL"
  region       = var.region
  project      = var.project_id
}

resource "google_compute_address" "internal_static_ip_wsfc_cluster_primary" {
  count        = var.is_fci_enabled ? 1 : 0
  name         = "static-ip-wsfc-pr-cluster-${var.name_project}-${var.name_region}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_database_usc1
  address_type = "INTERNAL"
  region       = var.region
  project      = var.project_id
}

resource "google_compute_address" "internal_static_ip_sql_wsfc_node_primary" {
  count        = var.is_fci_enabled ? 2 : 0
  name         = "static-ip-sql-wsfc-pr-node-${var.name_project}-${var.name_region}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_database_usc1
  address_type = "INTERNAL"
  region       = var.region
  project      = var.project_id
}

resource "google_compute_address" "internal_static_ip_sql_wsfc_witness_primary" {
  count        = var.is_fci_enabled ? 1 : 0
  name         = "static-ip-sql-wsfc-pr-witness-${var.name_project}-${var.name_region}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_database_usc1
  address_type = "INTERNAL"
  region       = var.region
  project      = var.project_id
}

resource "google_compute_address" "internal_static_ip_pbi_sql" {
  count        = var.num_instances_report_sql
  name         = "static-ip-pbi-sql-${var.name_project}-${var.name_region}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_database_usc1
  address_type = "INTERNAL"
  region       = var.region
  project      = var.project_id
}

resource "google_compute_address" "internal_static_ip_int_sql_wsfc_cluster" {
  count        = var.is_fci_enabled ? 1 : 0
  name         = "static-ip-int-sql-wsfc-cluster-${var.name_project}-${var.name_region}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_database_usc1
  address_type = "INTERNAL"
  region       = var.region
  project      = var.project_id
}

resource "google_compute_address" "internal_static_ip_sql_wsfc_dtc_primary" {
  count        = var.is_fci_enabled ? 1 : 0
  name         = "static-ip-sql-wsfc-pr-dtc-${var.name_project}-${var.name_region}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_database_usc1
  address_type = "INTERNAL"
  region       = var.region
  project      = var.project_id
}

resource "google_compute_address" "internal_static_ip_interface" {

  count        = var.num_instances_interface
  name         = "static-ip-interface-${var.name_project}-${var.name_region}-${format("%03d", count.index + 1)}"
  subnetwork   = var.subnet_web_usc1
  address_type = "INTERNAL"
  region       = var.region
  project      = var.project_id
}
# DR Instance Groups Configuration
resource "google_compute_instance_group" "umig_iis_web_server_dr" {
  for_each    = local.iis_web_server_zones_dr   
  name        = "umig-iis-web-dr-${each.key}-${var.name_region_dr}"
  description = "Unmanaged instance group for iis web server DR"
  zone        = each.key
  network     = data.google_compute_network.vpc_qsight.self_link

  instances   = [for vm_name in each.value : "https://www.googleapis.com/compute/v1/projects/${var.project_id}/zones/${each.key}/instances/${vm_name}"]

  named_port {
    name = "http"
    port = 80
  }
  named_port {
    name = "https"
    port = 443
  }
  named_port {
    name = "http-81"
    port = 81
  }
  named_port {
    name = "http-85"
    port = 85
  }
  named_port {
    name = "http-86"
    port = 86
  }

  depends_on = [
    module.vm_iis_web_dr
  ]
}

resource "google_compute_instance_group" "umig_web_server_dr" {
  for_each    = local.web_server_zones_dr  
  name        = "umig-web-dr-${each.key}-${var.name_region_dr}"
  description = "Unmanaged instance group for web traffic DR in ${each.key} zone"
  zone        = each.key
  network     = data.google_compute_network.vpc_qsight.self_link

  instances   = [for vm_name in each.value : "https://www.googleapis.com/compute/v1/projects/${var.project_id}/zones/${each.key}/instances/${vm_name}"]

  named_port {
    name = "http"
    port = 80
  }

  named_port {
    name = "https"
    port = 443
  }

  depends_on = [
    module.vm_web_dr
  ]
}

resource "google_compute_instance_group" "umig_web_service_dr" {
  for_each    = local.web_service_zones_dr  
  name        = "umig-web-service-dr-${each.key}-${var.name_region_dr}"
  zone        = each.key
  description = "Unmanaged instance group for web traffic DR in ${each.key} zone"
  instances   = [for vm_name in each.value : "https://www.googleapis.com/compute/v1/projects/${var.project_id}/zones/${each.key}/instances/${vm_name}"]
  network     = data.google_compute_network.vpc_qsight.self_link

  named_port {
    name = "https"
    port = 443
  }

  depends_on = [
    module.vm_ws_dr
  ]
}

resource "google_compute_instance_group" "umig_int_server_dr" {
  for_each    = local.int_server_zones_dr  
  name        = "umig-interface-server-dr-${each.key}-${var.name_region_dr}"
  zone        = each.key
  description = "Unmanaged instance group for interface DR in ${each.key} zone"
  instances   = [for vm_name in each.value : "https://www.googleapis.com/compute/v1/projects/${var.project_id}/zones/${each.key}/instances/${vm_name}"]
  network     = data.google_compute_network.vpc_qsight.self_link

  named_port {
    name = "sftp"
    port = 22
  }
  named_port {
    name = "http"
    port = 443
  }

  depends_on = [
    module.vm_int_dr
  ]
}

# DR Instance Group for SQL WSFC Nodes
resource "google_compute_instance_group" "umig_sql_wsfc_nodes_dr" {
  for_each    = local.sql_wsfc_nodes_zones_dr
  name        = "umig-sql-wsfc-nodes-dr-${each.key}-${var.name_region_dr}"
  zone        = each.key
  description = "Unmanaged instance group for SQL WSFC nodes DR in ${each.key} zone"
  instances   = [for vm_name in each.value : "https://www.googleapis.com/compute/v1/projects/${var.project_id}/zones/${each.key}/instances/${vm_name}"]
  network     = data.google_compute_network.vpc_qsight.self_link

  named_port {
    name = "sql"
    port = 1433
  }

  named_port {
    name = "mirroring"
    port = 5022
  }

  depends_on = [
    module.vm_sql_wsfc_nodes_dr
  ]
}

# DR instance group mappings
locals {
    
  iis_web_server_zones_dr = {
    for zone, instances in local.vm_iis_web_names_by_zone_dr : 
    zone => instances if length(instances) > 0
  }
  
  web_server_zones_dr = {
    for zone, instances in local.vm_web_names_by_zone_dr : 
    zone => instances if length(instances) > 0
  }
  
  web_service_zones_dr = {
    for zone, instances in local.vm_ws_names_by_zone_dr : 
    zone => instances if length(instances) > 0
  }
  
  int_server_zones_dr = {
    for zone, instances in local.vm_int_names_by_zone_dr : 
    zone => instances if length(instances) > 0
  }

  sql_wsfc_nodes_zones_dr = {
    for zone, instances in local.vm_sql_wsfc_node_names_by_zone_dr : 
    zone => instances if length(instances) > 0
  }

  # DR instance group self links
  umig_web_server_dr_links = [
    for group in google_compute_instance_group.umig_web_server_dr : group.self_link
  ]
  
  umig_web_service_dr_links = [
    for group in google_compute_instance_group.umig_web_service_dr : group.self_link
  ]
  
  umig_iis_web_server_dr_links = [
    for group in google_compute_instance_group.umig_iis_web_server_dr : group.self_link
  ]
  
  umig_int_server_dr_links = [
    for group in google_compute_instance_group.umig_int_server_dr : group.self_link
  ]


  # Add SQL WSFC DR instance group self links
  umig_sql_wsfc_nodes_dr_links = [
    for group in google_compute_instance_group.umig_sql_wsfc_nodes_dr : group.self_link
  ]
}
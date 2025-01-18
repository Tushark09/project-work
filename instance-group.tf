resource "google_compute_instance_group" "umig_iis_web_server" {
  for_each    = local.vm_iis_web_names_by_zone
  name        = "umig-iis-web-${each.key}-${var.name_region}"
  description = "Unmanaged instance group for iis web server"
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
    module.vm_iis_web
  ]
}


resource "google_compute_instance_group" "umig_web_server" {
  for_each    = local.vm_web_names_by_zone

  name        = "umig-web-${each.key}-${var.name_region}"  # Unique name per zone
  description = "Unmanaged instance group for web traffic in ${each.key} zone"
  zone        = each.key                       # The zone for the instance group
  network     = data.google_compute_network.vpc_qsight.self_link

  # Construct instance URLs based on zone and VM names
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
    module.vm_web  # Ensure the instance group depends on all VM instances
  ]
}



resource "google_compute_instance_group" "umig_web_service" {
  for_each    = local.vm_ws_names_by_zone
  name        = "umig-web-service-${each.key}-${var.name_region}"
  zone        = each.key
  description = "Unmanaged instance group for web traffic in ${each.key} zone"
  instances   = [for vm_name in each.value : "https://www.googleapis.com/compute/v1/projects/${var.project_id}/zones/${each.key}/instances/${vm_name}"]
  network     = data.google_compute_network.vpc_qsight.self_link

  named_port {
    name = "https"
    port = 443
  }

  depends_on = [
    module.vm_ws,
  ]
}

resource "google_compute_instance_group" "umig_int_server" {
  for_each =   local.vm_interface_names_by_zone
  name        = "umig-interface-server-${each.key}-${var.name_region}"
  zone        = each.key
  description = "Unmanaged instance group for interface in ${each.key} zone"
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
    module.vm_interface
  ]
}

resource "google_compute_instance_group" "umig_sql_wsfc_nodes" {
  for_each =   local.vm_sql_wsfc_nodes_names_by_zone
  name        = "umig-sql-wsfc-nodes-${each.key}-${var.name_region}"
  zone        = each.key
  description = "Unmanaged instance group for interface in ${each.key} zone"
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
    module.vm_sql_wsfc_nodes
  ]
}

resource "google_compute_instance_group" "umig_sql_wsfc_nodes_primary" {
  for_each =   local.vm_sql_wsfc_pr_nodes_names_by_zone
  name        = "umig-sql-wsfc-pr-nodes-${each.key}-${var.name_region}"
  zone        = each.key
  description = "Unmanaged instance group for interface in ${each.key} zone"
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
    module.vm_sql_wsfc_nodes
  ]
}

# Data sources for shared VPC network and subnet
data "google_compute_network" "vpc_qsight" {
  name                    = var.network_web_usc1_mig
  project                 = var.host_project_id  
}

data "google_compute_subnetwork" "subnet_qsight" {
  name                    = var.subnet_web_usc1_mig
  region                  = var.region
  project                 = var.host_project_id  
}

# Collect all unmanaged instance groups' self_links into a list
locals {
  umig_int_server_links = [for group in google_compute_instance_group.umig_int_server : group.self_link]
  umig_web_server_links = [for group in google_compute_instance_group.umig_web_server : group.self_link]
  umig_web_service_links = [for group in google_compute_instance_group.umig_web_service : group.self_link]
  umig_iis_web_server_links = [for group in google_compute_instance_group.umig_iis_web_server : group.self_link]
  umig_sql_wsfc_nodes_links = [for group in google_compute_instance_group.umig_sql_wsfc_nodes : group.self_link]
  umig_sql_wsfc_pr_nodes_links = [for group in google_compute_instance_group.umig_sql_wsfc_nodes_primary : group.self_link]
}
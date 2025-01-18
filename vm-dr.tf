# Use the same secret manager data source as primary config
data "google_secret_manager_secret_version" "domain_join_secrets_dr" {
  for_each = {
    dc_ip                = var.dc_ip_secret_version
    domain_name          = var.domain_name_secret_version
    domain_join_username = var.domain_join_username_secret_version
    domain_join_password = var.domain_join_password_secret_version
    dns_server           = var.dns_server_secret_version
    azure_devops_url     = var.azure_devops_url_version
    azure_devops_pat     = var.azure_devops_pat_version  
  }
  secret  = each.key
  version = each.value
  project = var.project_id
}

# DR version of VM modules - only created when is_dr_enabled = true
module "vm_int_dr" {
  source  = "./modules/compute-vm"
  count = var.num_instances_int_dr 
  project_id = var.project_id
  zone    = element(var.dr_available_zones, count.index % length(var.dr_available_zones))  
  name    = "vm-int-dr-${var.name_project}-${var.name_region_dr}-${format("%03d", count.index + 1)}"
  network_interfaces = [{
    network    = var.network
    subnetwork = var.subnet_web_dr 
    addresses  = {
      internal = google_compute_address.internal_static_ip_int_dr[count.index].address
    }
  }]
  boot_disk = {
    initialize_params = {
      image = var.source_image_int
      size  = var.boot_disk_size_int
      type  = var.boot_disk_type_int
      provisioned_iops = 15000
      provisioned_throughput = 2400
    }
  }
  attached_disks = var.additional_disks_int
  service_account = {
    email  = module.vm_service_account.email
    scopes = var.scopes_int
  }
  instance_type = var.machine_type_int
  depends_on    = [google_compute_address.internal_static_ip_int_dr]
  tags          = ["qsight-int-servers", "wsfc"]
  metadata = {
    windows-startup-script-ps1 = templatefile("./modules/startup-scripts/startup-script.ps1", {
      hostname             = "DR-${var.hostname_int[count.index]}"
      dc_ip                = data.google_secret_manager_secret_version.domain_join_secrets_dr["dc_ip"].secret_data
      dns_server           = data.google_secret_manager_secret_version.domain_join_secrets_dr["dns_server"].secret_data
      domain_name          = data.google_secret_manager_secret_version.domain_join_secrets_dr["domain_name"].secret_data
      domain_join_username = data.google_secret_manager_secret_version.domain_join_secrets_dr["domain_join_username"].secret_data
      domain_join_password = data.google_secret_manager_secret_version.domain_join_secrets_dr["domain_join_password"].secret_data
      env                  = "${var.environment}-dr"
      ou_path              = var.ou_path
      partition_config     = jsonencode(var.partition_config_int)
    })
  }
}


module "vm_sql_dr" {
  source  = "./modules/compute-vm"
  count   = var.is_fci_enabled ? 0 : var.num_instances_sql_dr
  project_id = var.project_id
  zone    = element(var.dr_available_zones, count.index % length(var.dr_available_zones))
  name    = "vm-sql-dr-${var.name_project}-${var.name_region_dr}-${format("%03d", count.index + 1)}"
  network_interfaces = [{
    network    = var.network
    subnetwork = var.subnet_database_dr
    addresses  = {
      internal = google_compute_address.internal_static_ip_sql_dr[count.index].address
    }
  }]
  boot_disk = {
    initialize_params = {
      image = var.source_image_sql
      size  = var.boot_disk_size_sql
      type  = var.boot_disk_type_sql
      provisioned_iops = 15000
      provisioned_throughput = 2400
    }
  }
  attached_disks  = var.additional_disks_sql
  service_account = {
    email  = module.vm_service_account.email
    scopes = var.scopes_sql
  }
  instance_type = var.machine_type_sql
  depends_on    = [google_compute_address.internal_static_ip_sql_dr]
  tags          = ["qsight-database-servers"]
  metadata = {
    windows-startup-script-ps1 = templatefile("./modules/startup-scripts/startup-script.ps1", {
      hostname             = "DR-${var.hostname_sql[count.index]}"
      dc_ip                = data.google_secret_manager_secret_version.domain_join_secrets_dr["dc_ip"].secret_data
      dns_server           = data.google_secret_manager_secret_version.domain_join_secrets_dr["dns_server"].secret_data
      domain_name          = data.google_secret_manager_secret_version.domain_join_secrets_dr["domain_name"].secret_data
      domain_join_username = data.google_secret_manager_secret_version.domain_join_secrets_dr["domain_join_username"].secret_data
      domain_join_password = data.google_secret_manager_secret_version.domain_join_secrets_dr["domain_join_password"].secret_data
      env                  = "${var.environment}-dr"
      ou_path              = var.ou_path
      partition_config     = jsonencode(var.partition_config_sql)
    })
  }
}

module "vm_int_sql_dr" {
  source  = "./modules/compute-vm"
  count = var.num_instances_int_sql_dr 
  project_id = var.project_id
  zone    = element(var.dr_available_zones, count.index % length(var.dr_available_zones))
  name    = "vm-int-sql-dr-${var.name_project}-${var.name_region_dr}-${format("%03d", count.index + 1)}"
  network_interfaces = [{
    network    = var.network
    subnetwork = var.subnet_database_dr
    addresses  = {
      internal = google_compute_address.internal_static_ip_int_sql_dr[count.index].address
    }
  }]
  boot_disk = {
    initialize_params = {
      image = var.source_image_int_sql
      size  = var.boot_disk_size_int_sql
      type  = var.boot_disk_type_int_sql
      provisioned_iops = 15000
      provisioned_throughput = 2400
    }
  }
  attached_disks  = var.additional_disks_int_sql
  service_account = {
    email  = module.vm_service_account.email
    scopes = var.scopes_int_sql
  }
  instance_type = var.machine_type_int_sql
  depends_on    = [google_compute_address.internal_static_ip_int_sql_dr]
  tags          = ["qsight-int-database-servers", "wsfc"]
  metadata = {
    windows-startup-script-ps1 = templatefile("./modules/startup-scripts/startup-script.ps1", {
      hostname             = "DR-${var.hostname_int_sql[count.index]}"
      dc_ip                = data.google_secret_manager_secret_version.domain_join_secrets_dr["dc_ip"].secret_data
      dns_server           = data.google_secret_manager_secret_version.domain_join_secrets_dr["dns_server"].secret_data
      domain_name          = data.google_secret_manager_secret_version.domain_join_secrets_dr["domain_name"].secret_data
      domain_join_username = data.google_secret_manager_secret_version.domain_join_secrets_dr["domain_join_username"].secret_data
      domain_join_password = data.google_secret_manager_secret_version.domain_join_secrets_dr["domain_join_password"].secret_data
      env                  = "${var.environment}-dr"
      ou_path              = var.ou_path
      partition_config     = jsonencode(var.partition_config_int_sql)
    })
  }
}


module "vm_int_db_dr" {
  source  = "./modules/compute-vm"
  count = var.num_instances_int_db_dr 
  project_id = var.project_id
  zone    = element(var.dr_available_zones, count.index % length(var.dr_available_zones))
  name    = "vm-int-db-dr-${var.name_project}-${var.name_region_dr}-${format("%03d", count.index + 1)}"
  network_interfaces = [{
    network    = var.network
    subnetwork = var.subnet_database_dr
    addresses  = {
      internal = google_compute_address.internal_static_ip_int_db_dr[count.index].address
    }
  }]
  boot_disk = {
    initialize_params = {
      image = var.source_image_int_db
      size  = var.boot_disk_size_int_db
      type  = var.boot_disk_type_int_db
      provisioned_iops = 15000
      provisioned_throughput = 2400
    }
  }
  attached_disks  = var.additional_disks_int_db
  service_account = {
    email  = module.vm_service_account.email
    scopes = var.scopes_int_db
  }
  instance_type = var.machine_type_int_db
  depends_on    = [google_compute_address.internal_static_ip_int_db_dr]
  tags          = ["qsight-int-database-servers", "wsfc"]
  metadata = {
    windows-startup-script-ps1 = templatefile("./modules/startup-scripts/startup-script.ps1", {
      hostname             = "DR-${var.hostname_int_db[count.index]}"
      dc_ip                = data.google_secret_manager_secret_version.domain_join_secrets_dr["dc_ip"].secret_data
      dns_server           = data.google_secret_manager_secret_version.domain_join_secrets_dr["dns_server"].secret_data
      domain_name          = data.google_secret_manager_secret_version.domain_join_secrets_dr["domain_name"].secret_data
      domain_join_username = data.google_secret_manager_secret_version.domain_join_secrets_dr["domain_join_username"].secret_data
      domain_join_password = data.google_secret_manager_secret_version.domain_join_secrets_dr["domain_join_password"].secret_data
      env                  = "${var.environment}-dr"
      ou_path              = var.ou_path
      partition_config     = jsonencode(var.partition_config_int_db)
    })
  }
}











module "vm_ws_dr" {
  source  = "./modules/compute-vm"
  count = var.num_instances_ws_dr 
  project_id = var.project_id
  zone    = element(var.dr_available_zones, count.index % length(var.dr_available_zones))
  name    = "vm-ws-dr-${var.name_project}-${var.name_region_dr}-${format("%03d", count.index + 1)}"
  network_interfaces = [{
    network    = var.network
    subnetwork = var.subnet_web_dr
    addresses  = {
      internal = google_compute_address.internal_static_ip_ws_dr[count.index].address
    }
  }]
  boot_disk = {
    initialize_params = {
      image = var.source_image_ws
      size  = var.boot_disk_size_ws
      type  = var.boot_disk_type_ws
      provisioned_iops = 15000
      provisioned_throughput = 2400
    }
  }
  attached_disks  = var.additional_disks_ws
  service_account = {
    email  = module.vm_service_account.email
    scopes = var.scopes_ws
  }
  instance_type = var.machine_type_ws
  depends_on    = [google_compute_address.internal_static_ip_ws_dr]
  tags          = ["qsight-web-services"]
  metadata = {
    windows-startup-script-ps1 = templatefile("./modules/startup-scripts/startup-script-web-ws-iis.ps1", {
      hostname             = "DR-${var.hostname_ws[count.index]}"
      dc_ip                = data.google_secret_manager_secret_version.domain_join_secrets_dr["dc_ip"].secret_data
      dns_server           = data.google_secret_manager_secret_version.domain_join_secrets_dr["dns_server"].secret_data
      domain_name          = data.google_secret_manager_secret_version.domain_join_secrets_dr["domain_name"].secret_data
      domain_join_username = data.google_secret_manager_secret_version.domain_join_secrets_dr["domain_join_username"].secret_data
      domain_join_password = data.google_secret_manager_secret_version.domain_join_secrets_dr["domain_join_password"].secret_data
      azure_devops_url     = data.google_secret_manager_secret_version.domain_join_secrets_dr["azure_devops_url"].secret_data
      azure_devops_pat     = data.google_secret_manager_secret_version.domain_join_secrets_dr["azure_devops_pat"].secret_data
      deployment_group_name = var.deployment_group_name_ws
      env                  = "${var.environment}-dr"
      ou_path              = var.ou_path
      partition_config     = jsonencode(var.partition_config_ws)
    })
  }
}

module "vm_web_dr" {
  source  = "./modules/compute-vm"
  count = var.num_instances_web_dr 
  project_id = var.project_id
  zone    = element(var.dr_available_zones, count.index % length(var.dr_available_zones))
  name    = "vm-web-dr-${var.name_project}-${var.name_region_dr}-${format("%03d", count.index + 1)}"
  network_interfaces = [{
    network    = var.network
    subnetwork = var.subnet_web_dr
    addresses  = {
      internal = google_compute_address.internal_static_ip_web_dr[count.index].address
    }
  }]
  boot_disk = {
    initialize_params = {
      image = var.source_image_web
      size  = var.boot_disk_size_web
      type  = var.boot_disk_type_web
      provisioned_iops = 15000
      provisioned_throughput = 2400
    }
  }
  attached_disks  = var.additional_disks_web
  service_account = {
    email  = module.vm_service_account.email
    scopes = var.scopes_web
  }
  instance_type = var.machine_type_web
  depends_on    = [google_compute_address.internal_static_ip_web_dr]
  tags          = ["qsight-web-servers"]
  metadata = {
    windows-startup-script-ps1 = templatefile("./modules/startup-scripts/startup-script-web-ws-iis.ps1", {
      hostname             = "DR-${var.hostname_web[count.index]}"
      dc_ip                = data.google_secret_manager_secret_version.domain_join_secrets_dr["dc_ip"].secret_data
      dns_server           = data.google_secret_manager_secret_version.domain_join_secrets_dr["dns_server"].secret_data
      domain_name          = data.google_secret_manager_secret_version.domain_join_secrets_dr["domain_name"].secret_data
      domain_join_username = data.google_secret_manager_secret_version.domain_join_secrets_dr["domain_join_username"].secret_data
      domain_join_password = data.google_secret_manager_secret_version.domain_join_secrets_dr["domain_join_password"].secret_data
      azure_devops_url     = data.google_secret_manager_secret_version.domain_join_secrets_dr["azure_devops_url"].secret_data
      azure_devops_pat     = data.google_secret_manager_secret_version.domain_join_secrets_dr["azure_devops_pat"].secret_data
      deployment_group_name = var.deployment_group_name_web
      env                  = "${var.environment}-dr"
      ou_path              = var.ou_path
      partition_config     = jsonencode(var.partition_config_web)
    })
  }
}

module "vm_report_sql_dr" {
  source  = "./modules/compute-vm"
  count = var.num_instances_report_sql_dr 
  project_id = var.project_id
  zone    = element(var.dr_available_zones, count.index % length(var.dr_available_zones))
  name    = "vm-report-sql-dr-${var.name_project}-${var.name_region_dr}-${format("%03d", count.index + 1)}"
  network_interfaces = [{
    network    = var.network
    subnetwork = var.subnet_database_dr
    addresses  = {
      internal = google_compute_address.internal_static_ip_report_sql_dr[count.index].address
    }
  }]
  boot_disk = {
    initialize_params = {
      image = var.source_image_report_sql
      size  = var.boot_disk_size_report_sql
      type  = var.boot_disk_type_report_sql
      provisioned_iops = 15000
      provisioned_throughput = 2400
    }
  }
  attached_disks  = var.additional_disks_report_sql
  service_account = {
    email  = module.vm_service_account.email
    scopes = var.scopes_report_sql
  }
  instance_type = var.machine_type_report_sql
  depends_on    = [google_compute_address.internal_static_ip_report_sql_dr]
  tags          = ["qsight-reporting-database-servers","qsight-database-servers"]
  metadata = {
    windows-startup-script-ps1 = templatefile("./modules/startup-scripts/startup-script.ps1", {
      hostname             = "DR-${var.hostname_report_sql[count.index]}"
      dc_ip                = data.google_secret_manager_secret_version.domain_join_secrets_dr["dc_ip"].secret_data
      dns_server           = data.google_secret_manager_secret_version.domain_join_secrets_dr["dns_server"].secret_data
      domain_name          = data.google_secret_manager_secret_version.domain_join_secrets_dr["domain_name"].secret_data
      domain_join_username = data.google_secret_manager_secret_version.domain_join_secrets_dr["domain_join_username"].secret_data
      domain_join_password = data.google_secret_manager_secret_version.domain_join_secrets_dr["domain_join_password"].secret_data
      env                  = "${var.environment}-dr"
      ou_path              = var.ou_path
      partition_config     = jsonencode(var.partition_config_report_sql)
    })
  }
}

module "vm_activegate_dr" {
  source  = "./modules/compute-vm"
  count = var.num_instances_activegate_dr 
  project_id = var.project_id
  zone    = element(var.dr_available_zones, count.index % length(var.dr_available_zones))
  name    = "vm-activegate-dr-${var.name_project}-${var.name_region_dr}-${format("%03d", count.index + 1)}"
  network_interfaces = [{
    network    = var.network
    subnetwork = var.subnet_web_dr
    addresses  = {
      internal = google_compute_address.internal_static_ip_activegate_dr[count.index].address
    }
  }]
  boot_disk = {
    initialize_params = {
      image = var.source_image_activegate
      size  = var.boot_disk_size_activegate
      type  = var.boot_disk_type_activegate
      provisioned_iops = 15000
      provisioned_throughput = 2400
    }
  }
  attached_disks  = var.additional_disks_activegate
  service_account = {
    email  = module.vm_service_account.email
    scopes = var.scopes_activegate
  }
  instance_type = var.machine_type_activegate
  depends_on    = [google_compute_address.internal_static_ip_activegate_dr]
  tags          = ["dynatrace-activegate"]
  metadata = {
    windows-startup-script-ps1 = templatefile("./modules/startup-scripts/startup-script.ps1", {
      hostname             = "DR-${var.hostname_dynatrace[count.index]}"
      dc_ip                = data.google_secret_manager_secret_version.domain_join_secrets_dr["dc_ip"].secret_data
      dns_server           = data.google_secret_manager_secret_version.domain_join_secrets_dr["dns_server"].secret_data
      domain_name          = data.google_secret_manager_secret_version.domain_join_secrets_dr["domain_name"].secret_data
      domain_join_username = data.google_secret_manager_secret_version.domain_join_secrets_dr["domain_join_username"].secret_data
      domain_join_password = data.google_secret_manager_secret_version.domain_join_secrets_dr["domain_join_password"].secret_data
      env                  = "${var.environment}-dr"
      ou_path              = var.ou_path
      partition_config     = jsonencode(var.partition_config_dynatrace)
    })
  }
}


# ADF VM DR Configuration
module "vm_adf_dr" {
  source  = "./modules/compute-vm"
  count = var.num_instances_adf_dr 
  project_id = var.project_id
  zone    = element(var.dr_available_zones, count.index % length(var.dr_available_zones))
  name = "vm-adf-dr-${var.name_project}-${var.name_region_dr}-${format("%03d", count.index + 1)}"
  network_interfaces = [{
    network    = var.network
    subnetwork = var.subnet_web_dr
    addresses = {
      internal = google_compute_address.internal_static_ip_adf_dr[count.index].address
    }
  }]
  boot_disk = {
    initialize_params = {
      image = var.source_image_adf
      size = var.boot_disk_size_adf
      type  = var.boot_disk_type_adf
      provisioned_iops = 15000
      provisioned_throughput = 2400
    }
  }
  attached_disks = var.additional_disks_adf
  service_account = {
    email = module.vm_service_account.email
    scopes = var.scopes_adf
  }
  instance_type = var.machine_type_adf
  depends_on = [google_compute_address.internal_static_ip_adf_dr]
  tags = ["adf-server"]
  metadata = {
    windows-startup-script-ps1 = templatefile("./modules/startup-scripts/startup-script.ps1", {
      hostname             = "DR-${var.hostname_adf[count.index]}"
      dc_ip                = data.google_secret_manager_secret_version.domain_join_secrets["dc_ip"].secret_data
      dns_server           = data.google_secret_manager_secret_version.domain_join_secrets["dns_server"].secret_data
      domain_name          = data.google_secret_manager_secret_version.domain_join_secrets["domain_name"].secret_data
      domain_join_username = data.google_secret_manager_secret_version.domain_join_secrets["domain_join_username"].secret_data
      domain_join_password = data.google_secret_manager_secret_version.domain_join_secrets["domain_join_password"].secret_data
      env                  = "${var.environment}-dr"
      ou_path              = var.ou_path
      partition_config     = jsonencode(var.partition_config_adf)
    })
  }
}

# IIS Web VM DR Configuration
module "vm_iis_web_dr" {
  source  = "./modules/compute-vm"
  count = var.num_instances_iis_web_dr 
  project_id = var.project_id
  zone    = element(var.dr_available_zones, count.index % length(var.dr_available_zones))
  name = "vm-iis-web-dr-${var.name_project}-${var.name_region_dr}-${format("%03d", count.index + 1)}"
  network_interfaces = [{
    network    = var.network
    subnetwork = var.subnet_web_dr
    addresses = {
      internal = google_compute_address.internal_static_ip_iis_web_dr[count.index].address
    }
  }]
  boot_disk = {
    initialize_params = {
      image = var.source_image_iis_web
      size = var.boot_disk_size_iis_web
      type  = var.boot_disk_type_iis_web
      provisioned_iops = 15000
      provisioned_throughput = 2400
    }
  }
  attached_disks = var.additional_disks_iis_web
  service_account = {
    email = module.vm_service_account.email
    scopes = var.scopes_iis_web
  }
  instance_type = var.machine_type_iis_web
  depends_on = [google_compute_address.internal_static_ip_iis_web_dr]
  tags = ["qsight-web-servers"]
  metadata = {
    windows-startup-script-ps1 = templatefile("./modules/startup-scripts/startup-script-web-ws-iis.ps1", {
      hostname             = "DR-${var.hostname_iis[count.index]}"
      dc_ip                = data.google_secret_manager_secret_version.domain_join_secrets["dc_ip"].secret_data
      dns_server           = data.google_secret_manager_secret_version.domain_join_secrets["dns_server"].secret_data
      domain_name          = data.google_secret_manager_secret_version.domain_join_secrets["domain_name"].secret_data
      domain_join_username = data.google_secret_manager_secret_version.domain_join_secrets["domain_join_username"].secret_data
      domain_join_password = data.google_secret_manager_secret_version.domain_join_secrets["domain_join_password"].secret_data
      azure_devops_url     = data.google_secret_manager_secret_version.domain_join_secrets["azure_devops_url"].secret_data
      azure_devops_pat     = data.google_secret_manager_secret_version.domain_join_secrets["azure_devops_pat"].secret_data
      deployment_group_name = var.deployment_group_name_iis
      env                  = "${var.environment}-dr"
      ou_path              = var.ou_path
      partition_config     = jsonencode(var.partition_config_iis)
    })
  }
}


# Power BI Gateway DR Configuration
module "vm_pbi_gateway_dr" {
  source  = "./modules/compute-vm"
  count = var.num_instances_pbi_gateway_dr 
  project_id = var.project_id
  zone    = element(var.dr_available_zones, count.index % length(var.dr_available_zones))
  name = "vm-pbi-gateway-dr-${var.name_project}-${var.name_region_dr}-${format("%03d", count.index + 1)}"
  network_interfaces = [{
    network    = var.network
    subnetwork = var.subnet_web_dr
    addresses = {
      internal = google_compute_address.internal_static_ip_pbi_gateway_dr[count.index].address
    }
  }]
  boot_disk = {
    initialize_params = {
      image = var.source_image_pbi_gateway
      size = var.boot_disk_size_pbi_gateway
    }
  }
  attached_disks = var.additional_disks_pbi_gateway
  service_account = {
    email = module.vm_service_account.email
    scopes = var.scopes_pbi_gateway
  }
  instance_type = var.machine_type_pbi_gateway
  depends_on = [google_compute_address.internal_static_ip_pbi_gateway_dr]
  tags = ["qsight-database-servers", "qsight-reporting-database-servers", "qsight-power-bi-sql-servers"]
  metadata = {
    windows-startup-script-ps1 = templatefile("./modules/startup-scripts/startup-script.ps1", {
      hostname             = "DR-${var.hostname_pbi_gateway[count.index]}"
      dc_ip                = data.google_secret_manager_secret_version.domain_join_secrets["dc_ip"].secret_data
      dns_server           = data.google_secret_manager_secret_version.domain_join_secrets["dns_server"].secret_data
      domain_name          = data.google_secret_manager_secret_version.domain_join_secrets["domain_name"].secret_data
      domain_join_username = data.google_secret_manager_secret_version.domain_join_secrets["domain_join_username"].secret_data
      domain_join_password = data.google_secret_manager_secret_version.domain_join_secrets["domain_join_password"].secret_data
      env                  = "${var.environment}-dr"
      ou_path              = var.ou_path
      partition_config     = jsonencode(var.partition_config_pbi_gateway)
    })
  }
}

module "vm_sql_wsfc_nodes_dr" {
  source  = "./modules/compute-vm"
  count = var.is_fci_enabled && var.is_dr_enabled ? 2 : 0  
  project_id = var.project_id
  zone    = element(var.dr_available_zones, count.index % length(var.dr_available_zones))  
  name    = "vm-sql-wsfc-node-dr-${var.name_project}-${var.name_region_dr}-${format("%03d", count.index + 1)}"
  network_interfaces = [{
    network    = var.network
    subnetwork = var.subnet_database_dr  
    addresses  = {
      internal = google_compute_address.internal_static_ip_sql_wsfc_node_dr[count.index].address
    }
  }]
  boot_disk = {
    initialize_params = {
      image = var.source_image_sql
      size  = var.boot_disk_size_sql_wsfc
      type  = var.boot_disk_type_sql_wsfc
      provisioned_iops = 15000
      provisioned_throughput = 2400
    }
  }
  attached_disks  = var.additional_disks_sql_wsfc
  service_account = {
    email  = module.vm_service_account.email
    scopes = var.scopes_sql
  }
  instance_type = var.machine_type_sql_wsfc_dr 
  tags          = ["qsight-database-servers", "wsfc", "wsfc-node"]
  metadata = {
    windows-startup-script-ps1 = templatefile("./modules/startup-scripts/startup-script.ps1", {
      hostname             = "DR-${var.hostname_sql_wsfc_node[count.index]}"
      dc_ip                = data.google_secret_manager_secret_version.domain_join_secrets_dr["dc_ip"].secret_data
      dns_server           = data.google_secret_manager_secret_version.domain_join_secrets_dr["dns_server"].secret_data
      domain_name          = data.google_secret_manager_secret_version.domain_join_secrets_dr["domain_name"].secret_data
      domain_join_username = data.google_secret_manager_secret_version.domain_join_secrets_dr["domain_join_username"].secret_data
      domain_join_password = data.google_secret_manager_secret_version.domain_join_secrets_dr["domain_join_password"].secret_data
      env                  = "${var.environment}-dr"
      ou_path              = var.ou_path
      partition_config     = jsonencode(var.partition_config_wsfc_node)
    })
    enable-wsfc = true
    sysprep-specialize-script-ps1 = file("./modules/startup-scripts/specialize-node.ps1")
  }
}

module "vm_sql_wsfc_witness_dr" {
  source  = "./modules/compute-vm"
  count = var.is_fci_enabled && var.is_dr_enabled ? 1 : 0  
  project_id = var.project_id
  zone    = element(var.dr_available_zones, count.index % length(var.dr_available_zones))  
  name    = "vm-sql-wsfc-witness-dr-${var.name_project}-${var.name_region_dr}-${format("%03d", count.index + 1)}"
  network_interfaces = [{
    network    = var.network
    subnetwork = var.subnet_database_dr  
    addresses  = {
      internal = google_compute_address.internal_static_ip_sql_wsfc_witness_dr[count.index].address
    }
  }]
  boot_disk = {
    initialize_params = {
      image = var.source_image_sql_wsfc_witness
      size  = var.boot_disk_size_sql_wsfc
      type  = var.boot_disk_type_sql_wsfc
      provisioned_iops = 15000
      provisioned_throughput = 2400
    }
  }
  attached_disks  = var.additional_disks_sql_wsfc_witness
  service_account = {
    email  = module.vm_service_account.email
    scopes = var.scopes_sql
  }
  instance_type = var.machine_type_sql_wsfc_witness
  tags          = ["qsight-database-servers", "wsfc"]
  metadata = {
    windows-startup-script-ps1 = templatefile("./modules/startup-scripts/startup-script.ps1", {
      hostname             = "DR-${var.hostname_sql_wsfc_witness[count.index]}"
      dc_ip                = data.google_secret_manager_secret_version.domain_join_secrets_dr["dc_ip"].secret_data
      dns_server           = data.google_secret_manager_secret_version.domain_join_secrets_dr["dns_server"].secret_data
      domain_name          = data.google_secret_manager_secret_version.domain_join_secrets_dr["domain_name"].secret_data
      domain_join_username = data.google_secret_manager_secret_version.domain_join_secrets_dr["domain_join_username"].secret_data
      domain_join_password = data.google_secret_manager_secret_version.domain_join_secrets_dr["domain_join_password"].secret_data
      env                  = "${var.environment}-dr"
      ou_path              = var.ou_path
      partition_config     = jsonencode(var.partition_config_wsfc_witness)
    })
    sysprep-specialize-script-ps1 = "add-windowsfeature FS-FileServer"
  }
}

module "vm_pbi_sql_dr" {
  source  = "./modules/compute-vm"
  count =  var.num_instances_pbi_sql_dr
  project_id = var.project_id
  zone = element(var.dr_available_zones, count.index % length(var.dr_available_zones))
  name = "vm-pbi-sql-dr-${var.name_project}-${var.name_region_dr}-${format("%03d", count.index + 1)}"
  network_interfaces = [{
    network    = var.network
    subnetwork = var.subnet_database_dr
    addresses = {
      internal = google_compute_address.internal_static_ip_pbi_sql_dr[count.index].address
    }
  }]
  boot_disk = {
    initialize_params = {
      image = var.source_image_pbi_sql
      size = var.boot_disk_size_pbi_sql
      type = var.boot_disk_type_pbi_sql
      provisioned_iops = 15000
      provisioned_throughput = 2400
    }
  }
  attached_disks = var.additional_disks_pbi_sql
  service_account = {
    email = module.vm_service_account.email
    scopes = var.scopes_pbi_sql
  }
  instance_type = var.machine_type_pbi_sql
  depends_on = [google_compute_address.internal_static_ip_pbi_sql_dr]
  tags = ["qsight-database-servers","qsight-reporting-database-servers","qsight-power-bi-sql-servers"]
  metadata = {
    windows-startup-script-ps1 = templatefile("./modules/startup-scripts/startup-script.ps1", {
      hostname             = "DR-${var.hostname_pbi_sql[count.index]}"
      dc_ip                = data.google_secret_manager_secret_version.domain_join_secrets["dc_ip"].secret_data
      dns_server           = data.google_secret_manager_secret_version.domain_join_secrets_dr["dns_server"].secret_data
      domain_name          = data.google_secret_manager_secret_version.domain_join_secrets["domain_name"].secret_data
      domain_join_username = data.google_secret_manager_secret_version.domain_join_secrets["domain_join_username"].secret_data
      domain_join_password = data.google_secret_manager_secret_version.domain_join_secrets["domain_join_password"].secret_data
      env                  = "${var.environment}-dr" 
      ou_path              = var.ou_path
      partition_config     = jsonencode(var.partition_config_pbi_sql)
    })
  }
}

module "vm_sql_mirror_witness_dr" {
  source  = "./modules/compute-vm"
  count = var.is_fci_enabled && var.is_dr_enabled ? 1 : 0  
  project_id = var.project_id
  zone    = element(var.dr_available_zones, count.index % length(var.dr_available_zones))  
  name    = "vm-sql-mirror-witness-dr-${var.name_project}-${var.name_region_dr}-${format("%03d", count.index + 1)}"
  network_interfaces = [{
    network    = var.network
    subnetwork = var.subnet_database_dr  
    addresses  = {
      internal = google_compute_address.internal_static_ip_sql_mirror_witness_dr[count.index].address
    }
  }]
  boot_disk = {
    initialize_params = {
      image = var.source_image_sql_wsfc_witness
      size  = var.boot_disk_size_sql_wsfc
      type  = var.boot_disk_type_sql_wsfc
      provisioned_iops = 15000
      provisioned_throughput = 2400
    }
  }
  attached_disks  = var.additional_disks_sql_wsfc_witness
  service_account = {
    email  = module.vm_service_account.email
    scopes = var.scopes_sql
  }
  instance_type = var.machine_type_sql_wsfc_witness
  tags          = ["qsight-database-servers", "wsfc"]
  metadata = {
    windows-startup-script-ps1 = templatefile("./modules/startup-scripts/startup-script.ps1", {
      hostname             = "DR-${var.hostname_sql_mirror_witness[count.index]}"
      dc_ip                = data.google_secret_manager_secret_version.domain_join_secrets_dr["dc_ip"].secret_data
      dns_server           = data.google_secret_manager_secret_version.domain_join_secrets_dr["dns_server"].secret_data
      domain_name          = data.google_secret_manager_secret_version.domain_join_secrets_dr["domain_name"].secret_data
      domain_join_username = data.google_secret_manager_secret_version.domain_join_secrets_dr["domain_join_username"].secret_data
      domain_join_password = data.google_secret_manager_secret_version.domain_join_secrets_dr["domain_join_password"].secret_data
      env                  = "${var.environment}-dr"
      ou_path              = var.ou_path
      partition_config     = jsonencode(var.partition_config_wsfc_witness)
    })
    sysprep-specialize-script-ps1 = "add-windowsfeature FS-FileServer"
  }
}

locals {
 
# DR VM instances by zone
  vm_iis_web_names_by_zone_dr = {
    for zone in distinct(module.vm_iis_web_dr[*].zone) :
    zone => [for i, z in module.vm_iis_web_dr[*].zone : module.vm_iis_web_dr[i].name if z == zone]
  }
  
  vm_adf_names_by_zone_dr = {
    for zone in distinct(module.vm_adf_dr[*].zone) :
    zone => [for i, z in module.vm_adf_dr[*].zone : module.vm_adf_dr[i].name if z == zone]
  }
  
  vm_activegate_names_by_zone_dr = {
    for zone in distinct(module.vm_activegate_dr[*].zone) :
    zone => [for i, z in module.vm_activegate_dr[*].zone : module.vm_activegate_dr[i].name if z == zone]
  }
  
  vm_report_sql_names_by_zone_dr = {
    for zone in distinct(module.vm_report_sql_dr[*].zone) :
    zone => [for i, z in module.vm_report_sql_dr[*].zone : module.vm_report_sql_dr[i].name if z == zone]
  }
  
  vm_ws_names_by_zone_dr = {
    for zone in distinct(module.vm_ws_dr[*].zone) :
    zone => [for i, z in module.vm_ws_dr[*].zone : module.vm_ws_dr[i].name if z == zone]
  }
  
  vm_sql_names_by_zone_dr = {
    for zone in distinct(module.vm_sql_dr[*].zone) :
    zone => [for i, z in module.vm_sql_dr[*].zone : module.vm_sql_dr[i].name if z == zone]
  }
  
  vm_int_sql_names_by_zone_dr = {
    for zone in distinct(module.vm_int_sql_dr[*].zone) :
    zone => [for i, z in module.vm_int_sql_dr[*].zone : module.vm_int_sql_dr[i].name if z == zone]
  }
  
  vm_int_names_by_zone_dr = {
    for zone in distinct(module.vm_int_dr[*].zone) :
    zone => [for i, z in module.vm_int_dr[*].zone : module.vm_int_dr[i].name if z == zone]
  }
  
  vm_web_names_by_zone_dr = {
    for zone in distinct(module.vm_web_dr[*].zone) :
    zone => [for i, z in module.vm_web_dr[*].zone : module.vm_web_dr[i].name if z == zone]
  }

  vm_sql_wsfc_node_names_by_zone_dr = {
    for zone in distinct(module.vm_sql_wsfc_nodes_dr[*].zone) :
    zone => [for i, z in module.vm_sql_wsfc_nodes_dr[*].zone : module.vm_sql_wsfc_nodes_dr[i].name if z == zone]
  }
  
  vm_sql_wsfc_witness_names_by_zone_dr = {
    for zone in distinct(module.vm_sql_wsfc_witness_dr[*].zone) :
    zone => [for i, z in module.vm_sql_wsfc_witness_dr[*].zone : module.vm_sql_wsfc_witness_dr[i].name if z == zone]
  }

  vm_vm_pbi_sql_names_by_zone_dr = {
    for zone in distinct(module.vm_pbi_sql_dr[*].zone) :
    zone => [for i, z in module.vm_pbi_sql_dr[*].zone : module.vm_pbi_sql_dr[i].name if z == zone]
  }

}
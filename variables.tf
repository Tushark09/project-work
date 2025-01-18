variable "project_id" {
  description = "Variable for project ID"
  type        = string
}
variable "name_project" {
  description = "Short project string for VM hostnames"
  type        = string
}
variable "name_region" {
  description = "Short region string for VM hostnames"
  type        = string
}
variable "name_region_dr" {
  description = "Short region string for VM hostnames"
  type        = string
}
variable "region" {
  description = "region"
  type        = string
}
variable "environment" {
  type = string
}

variable "available_zones" {
  description = "Compute Instance Zone"
  type = list(string)
}
variable "network" {
  description = "Variable for QSight VPC"
  type        = string
}

variable "subnet_web_usc1" {
  description = "Variable for QSight web subnet"
  type        = string
}
variable "subnet_cloudrun_usc1" {
  description = "Variable for QSight cloudrun subnet"
  type        = string
}
variable "subnet_database_usc1" {
  description = "Variable for QSight database subnet"
  type        = string
}
variable "subnet_ilb_usc1" {
  description = "Variable for QSight ILB subnet"
  type        = string
}
variable "subnet_ilb_use5" {
  description = "Variable for QSight ILB subnet"
  type        = string
}


variable "source_image_int" {
  description = "source image"
  type        = string
}
variable "num_instances_int" {
  type = number
}

variable "machine_type_int" {
  description = "The machine type to be used for the instance."
  type        = string
}

variable "additional_disks_int" {
  description = "Additional disks, if options is null defaults will be used in its place. Source type is one of 'image' (zonal disks in vms and template), 'snapshot' (vm), 'existing', and null."
  type = list(object({
    name        = string
    device_name = optional(string)
    # TODO: size can be null when source_type is attach
    size              = string
    snapshot_schedule = optional(string)
    source            = optional(string)
    source_type       = optional(string)
    options = optional(
      object({
        auto_delete  = optional(bool, false)
        mode         = optional(string, "READ_WRITE")
        replica_zone = optional(string)
        type         = optional(string, "pd-balanced")
      }),
      {
        auto_delete  = true
        mode         = "READ_WRITE"
        replica_zone = null
        type         = "pd-balanced"
      }
    )
  }))
}

variable "scopes_int" {
  type = list(string)
}

variable "boot_disk_size_int" {
  description = "The size of the disk in GB."
  type        = number
}

variable "source_image_int_sql" {
  description = "source image"
  type        = string
}
variable "num_instances_int_sql" {
  type = number
}

variable "machine_type_int_sql" {
  description = "The machine type to be used for the instance."
  type        = string
}

variable "additional_disks_int_sql" {
  description = "Additional disks, if options is null defaults will be used in its place. Source type is one of 'image' (zonal disks in vms and template), 'snapshot' (vm), 'existing', and null."
  type = list(object({
    name        = string
    device_name = optional(string)
    # TODO: size can be null when source_type is attach
    size              = string
    snapshot_schedule = optional(string)
    source            = optional(string)
    source_type       = optional(string)
    options = optional(
      object({
        auto_delete  = optional(bool, false)
        mode         = optional(string, "READ_WRITE")
        replica_zone = optional(string)
        type         = optional(string, "pd-balanced")
      }),
      {
        auto_delete  = true
        mode         = "READ_WRITE"
        replica_zone = null
        type         = "pd-balanced"
      }
    )
  }))
}

variable "scopes_int_sql" {
  type = list(string)
}

variable "boot_disk_size_int_sql" {
  description = "The size of the disk in GB."
  type        = number
}

variable "source_image_sql" {
  description = "source image"
  type        = string
}

variable "source_image_sql_wsfc_witness" {
  description = "source image"
  type        = string
}


variable "machine_type_sql_wsfc" {
  description = "The machine type to be used for the instance."
  type        = string
}

variable "machine_type_sql_wsfc_witness" {
  description = "The machine type to be used for the instance."
  type        = string
}

variable "machine_type_sql" {
  description = "The machine type to be used for the instance."
  type        = string
}

variable "additional_disks_sql" {
  description = "Additional disks, if options is null defaults will be used in its place. Source type is one of 'image' (zonal disks in vms and template), 'snapshot' (vm), 'existing', and null."
  type = list(object({
    name        = string
    device_name = optional(string)
    # TODO: size can be null when source_type is attach
    size              = string
    snapshot_schedule = optional(string)
    source            = optional(string)
    source_type       = optional(string)
    options = optional(
      object({
        auto_delete  = optional(bool, false)
        mode         = optional(string, "READ_WRITE")
        replica_zone = optional(string)
        type         = optional(string, "pd-balanced")
      }),
      {
        auto_delete  = true
        mode         = "READ_WRITE"
        replica_zone = null
        type         = "pd-balanced"
      }
    )
  }))
}

variable "additional_disks_sql_wsfc" {
  description = "Additional disks, if options is null defaults will be used in its place. Source type is one of 'image' (zonal disks in vms and template), 'snapshot' (vm), 'existing', and null."
  type = list(object({
    name        = string
    device_name = optional(string)
    # TODO: size can be null when source_type is attach
    size              = string
    snapshot_schedule = optional(string)
    source            = optional(string)
    source_type       = optional(string)
    options = optional(
      object({
        auto_delete  = optional(bool, false)
        mode         = optional(string, "READ_WRITE")
        replica_zone = optional(string)
        type         = optional(string, "pd-balanced")
      }),
      {
        auto_delete  = true
        mode         = "READ_WRITE"
        replica_zone = null
        type         = "pd-balanced"
      }
    )
  }))
}

variable "additional_disks_sql_wsfc_primary" {
  description = "Additional disks, if options is null defaults will be used in its place. Source type is one of 'image' (zonal disks in vms and template), 'snapshot' (vm), 'existing', and null."
  type = list(object({
    name        = string
    device_name = optional(string)
    # TODO: size can be null when source_type is attach
    size              = string
    snapshot_schedule = optional(string)
    source            = optional(string)
    source_type       = optional(string)
    options = optional(
      object({
        auto_delete  = optional(bool, false)
        mode         = optional(string, "READ_WRITE")
        replica_zone = optional(string)
        type         = optional(string, "pd-balanced")
      }),
      {
        auto_delete  = true
        mode         = "READ_WRITE"
        replica_zone = null
        type         = "pd-balanced"
      }
    )
  }))
}

variable "additional_disks_sql_wsfc_witness" {
  description = "Additional disks, if options is null defaults will be used in its place. Source type is one of 'image' (zonal disks in vms and template), 'snapshot' (vm), 'existing', and null."
  type = list(object({
    name        = string
    device_name = optional(string)
    # TODO: size can be null when source_type is attach
    size              = string
    snapshot_schedule = optional(string)
    source            = optional(string)
    source_type       = optional(string)
    options = optional(
      object({
        auto_delete  = optional(bool, false)
        mode         = optional(string, "READ_WRITE")
        replica_zone = optional(string)
        type         = optional(string, "pd-balanced")
      }),
      {
        auto_delete  = true
        mode         = "READ_WRITE"
        replica_zone = null
        type         = "pd-balanced"
      }
    )
  }))
}

variable "scopes_sql" {
  type = list(string)
}

variable "boot_disk_size_sql" {
  description = "The size of the disk in GB."
  type        = number
}

variable "boot_disk_size_sql_wsfc" {
  description = "The size of the disk in GB."
  type        = number
}

variable "source_image_ws" {
  description = "source image"
  type        = string
}
variable "num_instances_ws" {
  type = number
}

variable "machine_type_ws" {
  description = "The machine type to be used for the instance."
  type        = string
}
variable "additional_disks_ws" {
  description = "Additional disks, if options is null defaults will be used in its place. Source type is one of 'image' (zonal disks in vms and template), 'snapshot' (vm), 'existing', and null."
  type = list(object({
    name        = string
    device_name = optional(string)
    # TODO: size can be null when source_type is attach
    size              = string
    snapshot_schedule = optional(string)
    source            = optional(string)
    source_type       = optional(string)
    options = optional(
      object({
        auto_delete  = optional(bool, false)
        mode         = optional(string, "READ_WRITE")
        replica_zone = optional(string)
        type         = optional(string, "pd-balanced")
      }),
      {
        auto_delete  = true
        mode         = "READ_WRITE"
        replica_zone = null
        type         = "pd-balanced"
      }
    )
  }))
}

variable "scopes_ws" {
  type = list(string)
}

variable "boot_disk_size_ws" {
  description = "The size of the disk in GB."
  type        = number
}

variable "source_image_web" {
  description = "source image"
  type        = string
}
variable "num_instances_web" {
  type = number
}

variable "machine_type_web" {
  description = "The machine type to be used for the instance."
  type        = string
}
variable "additional_disks_web" {
  description = "Additional disks, if options is null defaults will be used in its place. Source type is one of 'image' (zonal disks in vms and template), 'snapshot' (vm), 'existing', and null."
  type = list(object({
    name        = string
    device_name = optional(string)
    # TODO: size can be null when source_type is attach
    size              = string
    snapshot_schedule = optional(string)
    source            = optional(string)
    source_type       = optional(string)
    options = optional(
      object({
        auto_delete  = optional(bool, false)
        mode         = optional(string, "READ_WRITE")
        replica_zone = optional(string)
        type         = optional(string, "pd-balanced")
      }),
      {
        auto_delete  = true
        mode         = "READ_WRITE"
        replica_zone = null
        type         = "pd-balanced"
      }
    )
  }))
}

variable "scopes_web" {
  type = list(string)
}

variable "boot_disk_size_web" {
  description = "The size of the disk in GB."
  type        = number
}

variable "source_image_report_sql" {
  description = "source image"
  type        = string
}
variable "num_instances_report_sql" {
  type = number
}

variable "machine_type_report_sql" {
  description = "The machine type to be used for the instance."
  type        = string
}
variable "additional_disks_report_sql" {
  description = "Additional disks, if options is null defaults will be used in its place. Source type is one of 'image' (zonal disks in vms and template), 'snapshot' (vm), 'existing', and null."
  type = list(object({
    name        = string
    device_name = optional(string)
    # TODO: size can be null when source_type is attach
    size              = string
    snapshot_schedule = optional(string)
    source            = optional(string)
    source_type       = optional(string)
    options = optional(
      object({
        auto_delete  = optional(bool, false)
        mode         = optional(string, "READ_WRITE")
        replica_zone = optional(string)
        type         = optional(string, "pd-balanced")
      }),
      {
        auto_delete  = true
        mode         = "READ_WRITE"
        replica_zone = null
        type         = "pd-balanced"
      }
    )
  }))
}

variable "scopes_report_sql" {
  type = list(string)
}

variable "boot_disk_size_report_sql" {
  description = "The size of the disk in GB."
  type        = number
}

variable "source_image_activegate" {
  description = "source image"
  type        = string
}
variable "num_instances_activegate" {
  type = number
}

variable "machine_type_activegate" {
  description = "The machine type to be used for the instance."
  type        = string
}
variable "additional_disks_activegate" {
  description = "Additional disks, if options is null defaults will be used in its place. Source type is one of 'image' (zonal disks in vms and template), 'snapshot' (vm), 'existing', and null."
  type = list(object({
    name        = string
    device_name = optional(string)
    # TODO: size can be null when source_type is attach
    size              = string
    snapshot_schedule = optional(string)
    source            = optional(string)
    source_type       = optional(string)
    options = optional(
      object({
        auto_delete  = optional(bool, false)
        mode         = optional(string, "READ_WRITE")
        replica_zone = optional(string)
        type         = optional(string, "pd-balanced")
      }),
      {
        auto_delete  = true
        mode         = "READ_WRITE"
        replica_zone = null
        type         = "pd-balanced"
      }
    )
  }))
}

variable "scopes_activegate" {
  type = list(string)
}

variable "boot_disk_size_activegate" {
  description = "The size of the disk in GB."
  type        = number
}

variable "source_image_adf" {
  description = "source image"
  type        = string
}
variable "num_instances_adf" {
  type = number
}

variable "machine_type_adf" {
  description = "The machine type to be used for the instance."
  type        = string
}


variable "additional_disks_adf" {
  description = "Additional disks, if options is null defaults will be used in its place. Source type is one of 'image' (zonal disks in vms and template), 'snapshot' (vm), 'existing', and null."
  type = list(object({
    name        = string
    device_name = optional(string)
    # TODO: size can be null when source_type is attach
    size              = string
    snapshot_schedule = optional(string)
    source            = optional(string)
    source_type       = optional(string)
    options = optional(
      object({
        auto_delete  = optional(bool, false)
        mode         = optional(string, "READ_WRITE")
        replica_zone = optional(string)
        type         = optional(string, "pd-balanced")
      }),
      {
        auto_delete  = true
        mode         = "READ_WRITE"
        replica_zone = null
        type         = "pd-balanced"
      }
    )
  }))
}

variable "scopes_adf" {
  type = list(string)
}

variable "boot_disk_size_adf" {
  description = "The size of the disk in GB."
  type        = number
}

variable "activate_api_identities" {
  description = "The list of service identities (Google Managed service account for the API) to force-create for the project"
  type = list(object({
    api   = string
    roles = list(string)
  }))
  default = []
}

variable "activate_apis" {
  description = "The list of apis to activate within the project"
  type        = list(string)
  default     = []
}

variable "enable_apis" {
  description = "Whether to actually enable the APIs. If false, this module is a no-op"
  type        = bool
  default     = true
}

variable "source_image_iis_web" {
  description = "source image"
  type        = string
}
variable "num_instances_iis_web" {
  type = number
}

variable "machine_type_iis_web" {
  description = "The machine type to be used for the instance."
  type        = string
}
variable "additional_disks_iis_web" {
  description = "Additional disks, if options is null defaults will be used in its place. Source type is one of 'image' (zonal disks in vms and template), 'snapshot' (vm), 'existing', and null."
  type = list(object({
    name        = string
    device_name = optional(string)
    # TODO: size can be null when source_type is attach
    size              = string
    snapshot_schedule = optional(string)
    source            = optional(string)
    source_type       = optional(string)
    options = optional(
      object({
        auto_delete  = optional(bool, false)
        mode         = optional(string, "READ_WRITE")
        replica_zone = optional(string)
        type         = optional(string, "pd-balanced")
      }),
      {
        auto_delete  = true
        mode         = "READ_WRITE"
        replica_zone = null
        type         = "pd-balanced"
      }
    )
  }))
}

variable "scopes_iis_web" {
  type = list(string)
}

variable "boot_disk_size_iis_web" {
  description = "The size of the disk in GB."
  type        = number
}


# Variable declarations


variable "network_web_usc1_mig" {
  description = "Name of the shared VPC network"
  type        = string
  default     = "vpc-shared-dev"
}

variable "subnet_web_usc1_mig" {
  description = "Name of the shared subnet"
  type        = string
  default     = "sb-qsight-dev-int-usc1-1"
}

variable "host_project_id" {
  description = "Project ID of the shared VPC host project"
  type        = string
}

variable "project_number" {
  description = "The numeric identifier of the Google Cloud project"
  type        = string
}

variable "project_name" {
  description = "The numeric identifier of the Google Cloud project"
  type        = string
}


variable "memory_size_cloud_memorystore" {
  description = "The size of the disk in GB."
  type        = number
}
variable "connect_mode_ms" {
  description = "connect mode for memorystore"
  type        = string
}


# variable "org_id" {
#   description = "org id"
#   type        = string
# }

/* IAM */
 variable "miglab_admin_roles" {
  type    = list(string)
  default = [
    "roles/run.invoker",
    "roles/secretmanager.admin",
    "roles/iam.serviceAccountKeyAdmin",
    "roles/compute.admin",
    "roles/storage.admin",
    "roles/run.admin",
    "roles/iap.tunnelResourceAccessor",
    "roles/iam.serviceAccountUser",
    "roles/cloudsupport.techSupportEditor",
    "roles/logging.admin",
    "roles/pubsub.admin",
    "roles/dns.admin",
    "roles/compute.loadBalancerAdmin",
    "roles/compute.networkUser"
  ]
}


//variables for statup script
variable "hostname_ws" {
  description = "Desired hostname for the VM"
  type        = list(string)
}
variable "hostname_web" {
  description = "Desired hostname for the VM"
  type        = list(string)
}
variable "hostname_iis" {
  description = "Desired hostname for the VM"
  type        = list(string)
}
variable "hostname_sql" {
  description = "Desired hostname for the VM"
  type        = list(string)
}
variable "hostname_sql_wsfc_node" {
  description = "Desired hostname for the VM"
  type        = list(string)
}
variable "hostname_sql_wsfc_witness" {
  description = "Desired hostname for the VM"
  type        = list(string)
}
variable "hostname_report_sql" {
  description = "Desired hostname for the VM"
  type        = list(string)
}
variable "hostname_int" {
  description = "Desired hostname for the VM"
  type        = list(string)
}
variable "hostname_interface" {
  description = "Desired hostname for the VM"
  type        = list(string)
}
variable "hostname_int_sql" {
  description = "Desired hostname for the VM"
  type        = list(string)
}
variable "hostname_dynatrace" {
  description = "Desired hostname for the VM"
  type        = list(string)
}
variable "hostname_adf" {
  description = "Desired hostname for the VM"
  type        = list(string)
}
variable "hostname_pbi_gateway" {
  description = "Desired hostname for the VM"
  type        = list(string)
}
variable "hostname_sql_mirror_witness" {
  description = "Desired hostname for the VM"
  type        = list(string)
}
variable "hostname_sql_wsfc_node_primary" {
  description = "Desired hostname for the VM"
  type        = list(string)
}
variable "hostname_sql_wsfc_witness_primary" {
  description = "Desired hostname for the VM"
  type        = list(string)
}
variable "deployment_group_name_ws" {
  description = "Desired hostname for the VM"
  type        = string
}
variable "deployment_group_name_iis" {
  description = "Desired hostname for the VM"
  type        = string
}
variable "deployment_group_name_web" {
  description = "Desired hostname for the VM"
  type        = string
}

variable "partition_config_ws" {
  description = "Configuration for disk partitions on WS servers"
  type = list(object({
    label        = string
    drive_letter = string
  }))
}
variable "partition_config_pbi_gateway" {
  description = "Configuration for disk partitions on pbi sql servers"
  type = list(object({
    label        = string
    drive_letter = string
  }))
}

variable "partition_config_web" {
  description = "Configuration for disk partitions on Web servers"
  type = list(object({
    label        = string
    drive_letter = string
  }))
}

variable "partition_config_iis" {
  description = "Configuration for disk partitions on IIS servers"
  type = list(object({
    label        = string
    drive_letter = string
  }))
}

variable "partition_config_report_sql" {
  description = "Configuration for disk partitions on Reporting DB servers"
  type = list(object({
    label        = string
    drive_letter = string
  }))
}

variable "partition_config_sql" {
  description = "Configuration for disk partitions on DB servers"
  type = list(object({
    label        = string
    drive_letter = string
  }))
}

variable "partition_config_wsfc_node" {
  description = "Configuration for disk partitions on DB servers"
  type = list(object({
    label        = string
    drive_letter = string
  }))
}

variable "partition_config_wsfc_witness" {
  description = "Configuration for disk partitions on DB servers"
  type = list(object({
    label        = string
    drive_letter = string
  }))
}

variable "partition_config_int" {
  description = "Configuration for disk partitions on INT servers"
  type = list(object({
    label        = string
    drive_letter = string
  }))
}

variable "partition_config_int_sql" {
  description = "Configuration for disk partitions on INT SQL servers"
  type = list(object({
    label        = string
    drive_letter = string
  }))
}

variable "partition_config_dynatrace" {
  description = "Configuration for disk partitions on Dynatrace servers"
  type = list(object({
    label        = string
    drive_letter = string
  }))
}

variable "partition_config_adf" {
  description = "Configuration for disk partitions on ADF servers"
  type = list(object({
    label        = string
    drive_letter = string
  }))
}

variable "dc_ip_secret_version" {
  description = "Version of the dc_ip secret to use"
  type        = string
  default     = "latest"
}

variable "dns_server_secret_version" {
  description = "Version of the dns_server secret to use"
  type        = string
  default     = "latest"
}

variable "domain_name_secret_version" {
  description = "Version of the domain_name secret to use"
  type        = string
  default     = "latest"
}

variable "domain_join_username_secret_version" {
  description = "Version of the domain_join_username secret to use"
  type        = string
  default     = "latest"
}

variable "domain_join_password_secret_version" {
  description = "Version of the domain_join_password secret to use"
  type        = string
  default     = "latest"
}

variable "ou_path" {
  description = "OU path for domain join"
  type        = string
}

variable "azure_devops_url_version" {
  description = "Version of the azure_devops_url_version secret to use"
  type        = string
  default     = "latest"
}
variable "azure_devops_pat_version" {
  description = "Version of the azure_devops_pat_version secret to use"
  type        = string
  default     = "latest"
}

/* glb-casemgmt-web */
variable "glb_casemgmt_web_domain" {
  type = string
}

/* glb-qsight-api */
variable "glb_qsight_api_domain" {
  type = string
}

/* glb-qsight-iis-web */
variable "glb_qsight_iis_web_login_domain" {
  type = string
}

variable "glb_qsight_iis_web_paramobile_domain" {
  type = string
}

variable "glb_qsight_iis_web_admin_domain" {
  type = string
}

variable "glb_qsight_iis_web_landingapi_domain" {
  type = string
}

variable "glb_qsight_iis_web_webapp_domain" {
  type = string
}

variable "glb_qsight_iis_web_dashboard_domain" {
  type = string
}

variable "is_dr_enabled" {
  type = bool
  default = false
}

variable "boot_disk_type_adf" {
  description = "disk type."
  type        = string
}
variable "boot_disk_type_activegate" {
  description = "disk type."
  type        = string
}
variable "boot_disk_type_ws" {
  description = "disk type."
  type        = string
}
variable "boot_disk_type_web" {
  description = "disk type."
  type        = string
}
variable "boot_disk_type_iis_web" {
  description = "disk type."
  type        = string
}
variable "boot_disk_type_int" {
  description = "disk type."
  type        = string
}
variable "boot_disk_type_int_sql" {
  description = "disk type."
  type        = string
}
variable "boot_disk_type_sql" {
  description = "disk type."
  type        = string
}

variable "boot_disk_type_sql_wsfc" {
  description = "disk type."
  type        = string
}

variable "boot_disk_type_report_sql" {
  description = "disk type."
  type        = string
}

variable "is_fci_enabled" {
  type = bool
  default = false
}

//

variable "machine_type_sql_wsfc_dr" {
  description = "The machine type to be used for the instance."
  type        = string
}
variable "source_image_pbi_gateway" {
  description = "source image"
  type        = string
}
variable "num_instances_pbi_gateway" {
  type = number
}

variable "machine_type_pbi_gateway" {
  description = "The machine type to be used for the instance."
  type        = string
}
variable "additional_disks_pbi_gateway" {
  description = "Additional disks, if options is null defaults will be used in its place. Source type is one of 'image' (zonal disks in vms and template), 'snapshot' (vm), 'existing', and null."
  type = list(object({
    name        = string
    device_name = optional(string)
    # TODO: size can be null when source_type is attach
    size              = string
    snapshot_schedule = optional(string)
    source            = optional(string)
    source_type       = optional(string)
    options = optional(
      object({
        auto_delete  = optional(bool, false)
        mode         = optional(string, "READ_WRITE")
        replica_zone = optional(string)
        type         = optional(string, "pd-balanced")
      }),
      {
        auto_delete  = true
        mode         = "READ_WRITE"
        replica_zone = null
        type         = "pd-balanced"
      }
    )
  }))
}

variable "scopes_pbi_gateway" {
  type = list(string)
}

variable "boot_disk_size_pbi_gateway" {
  description = "The size of the disk in GB."
  type        = number
}

variable "domain-ipm" {
  type = string
  
}

variable "glb_web_ws_domain" {
  type = string
  
}
//

variable "dr_available_zones" {
  type = list(string)
  description = "List of available zones for DR region"
}

variable "dr_region" {
  type        = string
  description = "The region for DR resources"
}

variable "subnet_web_dr" {
  type        = string
  description = "The subnet for web tier in DR region"
}

variable "subnet_database_dr" {
  type        = string
  description = "The subnet for database tier in DR region"
}

# DR instance count variables
variable "num_instances_int_dr" {
  type        = number
  description = "Number of integration server instances for DR"
  default     = 0
}

variable "num_instances_int_sql_dr" {
  type        = number
  description = "Number of integration SQL server instances for DR"
  default     = 0
}

variable "num_instances_sql_dr" {
  type        = number
  description = "Number of SQL server instances for DR"
  default     = 0
}

variable "num_instances_ws_dr" {
  type        = number
  description = "Number of web service instances for DR"
  default     = 0
}

variable "num_instances_web_dr" {
  type        = number
  description = "Number of web server instances for DR"
  default     = 0
}

variable "num_instances_iis_web_dr" {
  type        = number
  description = "Number of IIS web server instances for DR"
  default     = 0
}

variable "num_instances_report_sql_dr" {
  type        = number
  description = "Number of reporting SQL server instances for DR"
  default     = 0
}

variable "num_instances_activegate_dr" {
  type        = number
  description = "Number of Dynatrace ActiveGate instances for DR"
  default     = 0
}

variable "num_instances_adf_dr" {
  type        = number
  description = "Number of ADF instances for DR"
  default     = 0
}

variable "num_instances_pbi_gateway_dr" {
  type        = number
  description = "Number of Power BI Gateway instances for DR"
  default     = 0
}


//pub-sub

variable "pubsub_fixed_reader_endpoint" {
  type = string
  
}


variable "pubsub_termsofusage_endpoint" {
  type = string
  
}

variable "health-check-errors_push_endpoint" {
  type = string
}

//

variable "source_image_pbi_sql" {
  description = "source image"
  type        = string
}
variable "num_instances_pbi_sql" {
  type = number
}


variable "num_instances_pbi_sql_dr" {
  type = number
}

variable "machine_type_pbi_sql" {
  description = "The machine type to be used for the instance."
  type        = string
}
variable "additional_disks_pbi_sql" {
  description = "Additional disks, if options is null defaults will be used in its place. Source type is one of 'image' (zonal disks in vms and template), 'snapshot' (vm), 'existing', and null."
  type = list(object({
    name        = string
    device_name = optional(string)
    # TODO: size can be null when source_type is attach
    size              = string
    snapshot_schedule = optional(string)
    source            = optional(string)
    source_type       = optional(string)
    options = optional(
      object({
        auto_delete  = optional(bool, false)
        mode         = optional(string, "READ_WRITE")
        replica_zone = optional(string)
        type         = optional(string, "pd-balanced")
      }),
      {
        auto_delete  = true
        mode         = "READ_WRITE"
        replica_zone = null
        type         = "pd-balanced"
      }
    )
  }))
}

variable "scopes_pbi_sql" {
  type = list(string)
}

variable "boot_disk_size_pbi_sql" {
  description = "The size of the disk in GB."
  type        = number
}

variable "hostname_pbi_sql" {
  description = "Desired hostname for the VM"
  type        = list(string)
}

variable "partition_config_pbi_sql" {
  description = "Configuration for disk partitions on DB servers"
  type = list(object({
    label        = string
    drive_letter = string
  }))
}


variable "boot_disk_type_pbi_sql" {
  description = "disk type."
  type        = string
}


variable "source_image_int_db" {
  description = "source image"
  type        = string
}
variable "num_instances_int_db_dr" {
  type = number
}

variable "num_instances_int_db" {
  type = number
}

variable "machine_type_int_db" {
  description = "The machine type to be used for the instance."
  type        = string
}

variable "boot_disk_type_int_db" {
  description = "disk type."
  type        = string
}

variable "additional_disks_int_db" {
  description = "Additional disks, if options is null defaults will be used in its place. Source type is one of 'image' (zonal disks in vms and template), 'snapshot' (vm), 'existing', and null."
  type = list(object({
    name        = string
    device_name = optional(string)
    # TODO: size can be null when source_type is attach
    size              = string
    snapshot_schedule = optional(string)
    source            = optional(string)
    source_type       = optional(string)
    options = optional(
      object({
        auto_delete  = optional(bool, false)
        mode         = optional(string, "READ_WRITE")
        replica_zone = optional(string)
        type         = optional(string, "pd-balanced")
      }),
      {
        auto_delete  = true
        mode         = "READ_WRITE"
        replica_zone = null
        type         = "pd-balanced"
      }
    )
  }))
}

variable "scopes_int_db" {
  type = list(string)
}

variable "boot_disk_size_int_db" {
  description = "The size of the disk in GB."
  type        = number
}

variable "hostname_int_db" {
  description = "Desired hostname for the VM"
  type        = list(string)
}

variable "partition_config_int_db" {
  description = "Configuration for disk partitions on INT SQL servers"
  type = list(object({
    label        = string
    drive_letter = string
  }))
}


variable "iap_user_roles" {
  description = "IAM roles for IAP tunnel access"
  type        = list(string)
  default = [
    "roles/iap.tunnelResourceAccessor",
    "roles/compute.viewer",
    "roles/iam.serviceAccountUser"
  ]
}

variable "health_check_filter" {
  description = "Complete filter string for health check monitoring"
  type        = string
}

variable "filter_severity" {
  description = "Severity level to filter logs"
  type        = string
  default     = "ERROR"
}



variable "dynatrace_filter" {
  description = "Complete filter string for dynatrace monitoring"
  type        = string
}






variable "source_image_interface" {
  description = "source image"
  type        = string
}
variable "num_instances_interface" {
  type = number
}

variable "machine_type_interface" {
  description = "The machine type to be used for the instance."
  type        = string
}

variable "additional_disks_interface" {
  description = "Additional disks, if options is null defaults will be used in its place. Source type is one of 'image' (zonal disks in vms and template), 'snapshot' (vm), 'existing', and null."
  type = list(object({
    name        = string
    device_name = optional(string)
    # TODO: size can be null when source_type is attach
    size              = string
    snapshot_schedule = optional(string)
    source            = optional(string)
    source_type       = optional(string)
    options = optional(
      object({
        auto_delete  = optional(bool, false)
        mode         = optional(string, "READ_WRITE")
        replica_zone = optional(string)
        type         = optional(string, "pd-balanced")
      }),
      {
        auto_delete  = true
        mode         = "READ_WRITE"
        replica_zone = null
        type         = "pd-balanced"
      }
    )
  }))
}

variable "scopes_interface" {
  type = list(string)
}

variable "boot_disk_size_interface" {
  description = "The size of the disk in GB."
  type        = number
}

variable "boot_disk_type_interface" {
  description = "disk type."
  type        = string
}

variable "partition_config_interface" {
  description = "Configuration for disk partitions on INT servers"
  type = list(object({
    label        = string
    drive_letter = string
  }))
}

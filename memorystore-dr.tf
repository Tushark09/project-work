# DR Memorystore Configuration
module "memorystore_dr" {
  source = "./modules/memorystore"
  count = var.is_dr_enabled ? 1 : 0
  name           = "mem-rd-dr-${var.name_project}-${var.name_region_dr}"
  project        = var.project_id
  region         = var.dr_region
  memory_size_gb = var.memory_size_cloud_memorystore
  enable_apis    = true

  authorized_network = "${var.network}"
  connect_mode      = var.connect_mode_ms
  transit_encryption_mode = "DISABLED"

  labels = {
    environment = "${var.environment}-dr"
  }
}
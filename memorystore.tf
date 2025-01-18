module "memorystore" {
  source = "./modules/memorystore"
  name           = "mem-rd-${var.name_project}-${var.name_region}"
  project        = var.project_id
  region         = var.region
  memory_size_gb = var.memory_size_cloud_memorystore
  enable_apis    = true

  authorized_network = "${var.network}"
  connect_mode = var.connect_mode_ms
  transit_encryption_mode = "DISABLED"

  labels = {
    environment = "${var.environment}"
  }

}
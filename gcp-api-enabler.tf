module "project_services" {
  source = "./modules/project-services"

  project_id                  = var.project_id
  activate_apis               = var.activate_apis
  activate_api_identities     = var.activate_api_identities
  enable_apis                 = var.enable_apis
  disable_services_on_destroy = false
  disable_dependent_services  = false
}
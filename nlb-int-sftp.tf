# # Create a static IP address for the load balancer
# resource "google_compute_address" "lb_int_sftp_ip" {
#   name         = "static-nlb-int-sftp-${var.name_project}-${var.name_region}-ip"
#   project      = var.project_id
#   region       = var.region
#   address_type = "EXTERNAL"
#   network_tier = "PREMIUM"
# }

# module "nlb-int-sftp" {
#   source     = "./modules/net-lb-ext"
#   project_id = var.project_id
#   region     = var.region
#   name       = "nlb-${var.name_project}-int-sftp-${var.name_region}"

#   backends = [{
#     group = google_compute_instance_group.umig_int_server.self_link
#   }]

#   backend_service_config = {
#     protocol = "TCP"
#     port     = 22
#   }

#   health_check_config = {
#     tcp = {
#       port = 22
#     }
#   }

#   forwarding_rules_config = {
#     default = {
#       ports     = [22]
#       protocol  = "TCP"
#       address = google_compute_address.lb_int_sftp_ip.address
#     }
#   }
# }

# # Output the IP address of the load balancer
# output "nlb_ip_address" {
#   value = google_compute_address.lb_int_sftp_ip.address
# }








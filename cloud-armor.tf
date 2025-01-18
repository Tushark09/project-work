
module "cloud-armor" {
  source  = "GoogleCloudPlatform/cloud-armor/google"
  version = "3.0.0"

  project_id                           = var.project_id
  name                                 = "${var.name_project}-cloud-armor-policy"
  description                          = "Cloud Armor policy with all preconfigured WAF rules"
  default_rule_action                  = "allow"
  type                                 = "CLOUD_ARMOR"
  layer_7_ddos_defense_enable          = true
  layer_7_ddos_defense_rule_visibility = "STANDARD"

  pre_configured_rules = {
    # "sqli-v33-stable" = {
    #   action          = "deny(403)"
    #   priority        = 1000
    #   description     = "SQL injection protection"
    #   preview         = false
    #   target_rule_set = "sqli-v33-stable"
    #   sensitivity_level = 2
    # }
    
    # "xss-v33-stable" = {
    #   action          = "deny(403)"
    #   priority        = 1001
    #   description     = "Cross-site scripting protection"
    #   preview         = false
    #   target_rule_set = "xss-v33-stable"
    #   sensitivity_level = 2
    # }
    
    # "lfi-v33-stable" = {
    #   action          = "deny(403)"
    #   priority        = 1002
    #   description     = "Local file inclusion protection"
    #   preview         = false
    #   target_rule_set = "lfi-v33-stable"
    #   sensitivity_level = 1
    # }
    
    # "rfi-v33-stable" = {
    #   action          = "deny(403)"
    #   priority        = 1003
    #   description     = "Remote file inclusion protection"
    #   preview         = false
    #   target_rule_set = "rfi-v33-stable"
    #   sensitivity_level = 1
    # }
    
    # "rce-v33-stable" = {
    #   action          = "deny(403)"
    #   priority        = 1004
    #   description     = "Remote code execution protection"
    #   preview         = false
    #   target_rule_set = "rce-v33-stable"
    #   sensitivity_level = 2
    # }
    
    # "methodenforcement-v33-stable" = {
    #   action          = "deny(403)"
    #   priority        = 1005
    #   description     = "Method enforcement"
    #   preview         = false
    #   target_rule_set = "methodenforcement-v33-stable"
    #   sensitivity_level = 1
    # }
    
    # "scannerdetection-v33-stable" = {
    #   action          = "deny(403)"
    #   priority        = 1006
    #   description     = "Scanner detection"
    #   preview         = false
    #   target_rule_set = "scannerdetection-v33-stable"
    #   sensitivity_level = 1
    # }
    
    # "protocolattack-v33-stable" = {
    #   action          = "deny(403)"
    #   priority        = 1007
    #   description     = "Protocol attack protection"
    #   preview         = false
    #   target_rule_set = "protocolattack-v33-stable"
    #   sensitivity_level = 1
    # }
    
    # "php-v33-stable" = {
    #   action          = "deny(403)"
    #   priority        = 1008
    #   description     = "PHP injection attack protection"
    #   preview         = false
    #   target_rule_set = "php-v33-stable"
    #   sensitivity_level = 1
    # }
    
    # "sessionfixation-v33-stable" = {
    #   action          = "deny(403)"
    #   priority        = 1009
    #   description     = "Session fixation attack protection"
    #   preview         = false
    #   target_rule_set = "sessionfixation-v33-stable"
    #   sensitivity_level = 1
    # }
    
    # "java-v33-stable" = {
    #   action          = "deny(403)"
    #   priority        = 1010
    #   description     = "Java attack protection"
    #   preview         = false
    #   target_rule_set = "java-v33-stable"
    #   sensitivity_level = 1
    # }
    
    # "nodejs-v33-stable" = {
    #   action          = "deny(403)"
    #   priority        = 1011
    #   description     = "NodeJS attack protection"
    #   preview         = false
    #   target_rule_set = "nodejs-v33-stable"
    #   sensitivity_level = 1
    # }
  }
}


output "policy" {
  description = "The created Cloud Armor security policy"
  value       = module.cloud-armor.policy
}

module "cloud-armor-edge-policy" {
  source  = "GoogleCloudPlatform/cloud-armor/google"
  version = "3.0.0"

  project_id                           = var.project_id
  name                                 = "${var.name_project}-cloud-armor-edge-policy"
  description                          = "Cloud Armor edge policy"
  default_rule_action                  = "allow"
  type                                 = "CLOUD_ARMOR_EDGE"
  layer_7_ddos_defense_enable          = true
  layer_7_ddos_defense_rule_visibility = "STANDARD"

}


output "policy-edge-policy" {
  description = "The created Cloud Armor edge security policy"
  value       = module.cloud-armor-edge-policy.policy
}
resource "google_dns_managed_zone" "sql-zone" {
  name        = "sql-zone"
  dns_name    = "${var.project_name}sql.net."
  description = "DNS zone"
  visibility  = "private"

    private_visibility_config {
    networks {
      network_url = var.network
    }
  }
}

resource "google_dns_record_set" "sql_wsfc_a_records" {
  name         = "wsfc.${var.project_name}sql.net."
  managed_zone = google_dns_managed_zone.sql-zone.name
  type         = "A"
  ttl          = 21600
  rrdatas      = [
    "10.244.170.10"   
  ]
}





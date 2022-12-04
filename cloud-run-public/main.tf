terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.87.0"
    }
  }
}

resource "google_compute_region_network_endpoint_group" "cloudrun_neg" {
  name                  = "${var.name}-cloudrun-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = var.cloudrun_name
  }
}

resource "google_compute_backend_service" "default" {
  name      = "${var.name}-cloudrun-backend"

  protocol  = "HTTP"
  port_name = "http"
  timeout_sec = 30

  enable_cdn  = var.enable_cdn
  connection_draining_timeout_sec  = 300

  log_config {
    enable = true
    sample_rate = 1.0
  }

  backend {
    group = google_compute_region_network_endpoint_group.cloudrun_neg.id
  }
}

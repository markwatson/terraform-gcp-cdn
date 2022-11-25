terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.87.0"
    }
  }
}

# Create an IP
resource "google_compute_global_address" "default" {
  project      = var.project
  name         = "${var.name}-address"
  ip_version   = "IPV4"
  address_type = "EXTERNAL"
}

# Create HTTP Rules
resource "google_compute_target_http_proxy" "http" {
  project = var.project
  name    = "${var.name}-http-proxy"
  url_map = google_compute_url_map.https_redirect.self_link
}

resource "google_compute_url_map" "https_redirect" {
  project = var.project
  name    = "${var.name}-https-redirect"
  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}

resource "google_compute_global_forwarding_rule" "http" {
  project    = var.project
  name       = "${var.name}-http-rule"
  target     = google_compute_target_http_proxy.http.self_link
  ip_address = google_compute_global_address.default.address
  port_range = "80"

  depends_on = [google_compute_global_address.default]

  labels = var.labels
}


# Create HTTPS Rules
resource "google_compute_global_forwarding_rule" "https" {
  project    = var.project
  name       = "${var.name}-https-rule"
  target     = google_compute_target_https_proxy.default.self_link
  ip_address = google_compute_global_address.default.address
  port_range = "443"
  depends_on = [google_compute_global_address.default]

  labels = var.labels
}

resource "google_compute_target_https_proxy" "default" {
  project = var.project
  name    = "${var.name}-https-proxy"
  url_map = google_compute_url_map.urlmap.self_link

  ssl_certificates = [ for cert in values(google_compute_managed_ssl_certificate.default) : cert.id ]
}

# SSL Certificates

# URL Map
resource "google_compute_url_map" "urlmap" {
  project  = var.project

  name        = "${var.name}-url-map"
  description = "URL map for ${var.name}"

  default_service = var.default_service

  dynamic "host_rule" {
    for_each = var.host_rules
    content {
      hosts        = [host_rule.key]
      path_matcher = "path-matcher-${replace(host_rule.key, ".", "-")}"
    }
  }

  dynamic "path_matcher" {
    for_each = var.host_rules
    content {
      name = "path-matcher-${replace(path_matcher.key, ".", "-")}"
      default_service = path_matcher.value
      # NOTE: We can extend this module to add path_rules here
    }
  }
}

# TODO: this will only support 10 domains for now.
resource "google_compute_managed_ssl_certificate" "default" {
  for_each = var.host_rules

  name = random_id.certificate[each.key].hex

  managed {
    domains = ["${each.key}."]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "random_id" "certificate" {
  for_each = var.host_rules

  byte_length = 4
  prefix      = "${var.name}-${replace(each.key, ".", "-")}-cert-"

  keepers = {
    domains = "${each.key}."
  }
}

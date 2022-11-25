terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.87.0"
    }
  }
}

resource "google_storage_bucket" "static-site" {
  name          = var.name
  location      = var.location
  force_destroy = true

  labels = var.labels
  
  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
  # cors {
  #   origin          = ["http://image-store.com"]
  #   method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
  #   response_header = ["*"]
  #   max_age_seconds = 3600
  # }
}

data "google_iam_policy" "bucket-policy" {
  binding {
    role = "roles/storage.admin"
    members = var.admin_members
  }

  binding {
    role = "roles/storage.legacyObjectReader"
    members = [
        "allUsers",
    ]
  }
}

resource "google_storage_bucket_iam_policy" "bucket-policy-resource" {
  bucket = google_storage_bucket.static-site.name
  policy_data = data.google_iam_policy.bucket-policy.policy_data
}


resource "google_storage_bucket_object" "index" {
  name   = "index.html"
  # Note this has to be relative to the root of the repo. 
  # It can also pull from github.
  source = "./static-site/resources/index.html"
  bucket = google_storage_bucket.static-site.name

  lifecycle {
    ignore_changes = all
  }
}

resource "google_storage_bucket_object" "not-found" {
  name   = "404.html"
  source = "./static-site/resources/404.html"
  bucket = google_storage_bucket.static-site.name

  lifecycle {
    ignore_changes = all
  }
}

resource "google_compute_backend_bucket" "backend" {
  name        = "${local.sanitized_name}-backend-bucket"
  bucket_name = google_storage_bucket.static-site.name
  enable_cdn  = true
  cdn_policy {
    # Low TTL for now.
    max_ttl = 300 # 5 min
    default_ttl = 300 # 5 min
    client_ttl = 300 # 5 min
  }
}

locals {
  sanitized_name = replace(var.name, ".", "-")
}
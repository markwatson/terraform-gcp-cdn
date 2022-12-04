terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.87.0"
    }
  }
}

# The service.
resource "google_cloud_run_service" "api" {
  name     = var.name
  location = var.location

  metadata {
    namespace = var.project
  }

  // Use a default image.
  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
      }
    }
  }

  // Ignore the default image, since deployments will change it.
  lifecycle {
    ignore_changes = [
      # Cloud build (setup below) updates these, so we don't want to change them. 
      template,
      metadata,
    ]
  }

}

# This is a public service.
data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.api.location
  project  = google_cloud_run_service.api.project
  service  = google_cloud_run_service.api.name

  policy_data = data.google_iam_policy.noauth.policy_data
}

resource "google_cloudbuild_trigger" "filename-trigger" {
  count = var.build_trigger ? 1 : 0

  description = "Push site from ${var.build_trigger_options.branch}."
  filename    = "cloudbuild.yaml"

  github {
    owner = var.build_trigger_options.github_owner
    name  = var.build_trigger_options.github_name
    push {
      branch = var.build_trigger_options.branch
    }
  }

  substitutions = {
    _DEPLOY_REGION = google_cloud_run_service.api.location
    _GCR_HOSTNAME  = "us.gcr.io"
    _PLATFORM      = "managed"
    _SERVICE_NAME  = google_cloud_run_service.api.name
    _DIR           = "."
  }
}

data "google_project" "project" {}

// TODO: Figure out exact permissions needed.
resource "google_project_iam_member" "cloudbuild_cloudrun_deployer" {
  count = var.build_trigger ? 1 : 0
  project = data.google_project.project.number
  role    = "roles/run.developer"
  member  = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

resource "google_project_iam_member" "cloudbuild_iam_deployer" {
  count = var.build_trigger ? 1 : 0
  project = data.google_project.project.number
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

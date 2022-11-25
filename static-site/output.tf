output "bucket" {
  value = resource.google_storage_bucket.static-site
}

output "backend" {
  value = resource.google_compute_backend_bucket.backend
}

output "ip_address" {
  value = resource.google_compute_global_address.default.address
  description = "The IP address of the load balancer"
}
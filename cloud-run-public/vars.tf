variable "project" {
  description = "The project ID to create the resources in."
  type        = string
}

variable "name" {
  description = "Name for the load balancer forwarding rule and prefix for supporting resources."
  type        = string
}

variable "region" {
  description = "The region to create the resources in."
  type        = string
}

variable "cloudrun_name" {
  description = "Name of the Cloud Run service to connect to."
  type        = string
}

variable "enable_cdn" {
  description = "Should we enable CDN for the backend service?"
  type        = bool
  default     = false
}

variable "cdn_policy" {
  description = "CDN policy for the backend service. See: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_service#nested_cdn_policy"
  type        = map(string)
  default     = {}
}
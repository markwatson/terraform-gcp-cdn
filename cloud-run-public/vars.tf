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

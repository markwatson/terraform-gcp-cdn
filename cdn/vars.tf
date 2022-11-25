variable "project" {
  description = "The project ID to create the resources in."
  type        = string
}

variable "name" {
  description = "Name for the load balancer forwarding rule and prefix for supporting resources."
  type        = string
}

variable "labels" {
  description = "The key is the label name and the value is the label value."
  type        = map(string)
  default     = {}
}

variable "host_rules" {
  description = "A map of each domain to the service to front."
  type        = map(string)
}

variable "default_service" {
  description = "The default service for this load balancer."
  type        = string
}
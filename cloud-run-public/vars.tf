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

variable "cache_mode" {
  description = "Cache mode for the CDN. Defaults to use origin headers. If you want to auto cache static content, then use CACHE_ALL_STATIC. If you want to cache everything, use FORCE_CACHE_ALL. If you use either of those values you can set explicit TTLs as well to optimize serve without using cache headers. See https://cloud.google.com/cdn/docs/using-cache-modes for details."
  type        = string
  default     = "USE_ORIGIN_HEADERS"
}

variable "default_ttl" {
  description = "Default TTL for the CDN cache, for items that don't have a cache header response. Defaults to 0 to ensure we use origin headers. See: https://cloud.google.com/cdn/docs/using-ttl-overrides"
  type        = number
  default     = 3600
}

variable "max_ttl" {
  description = "Specifies the maximum allowed TTL for cached content served by this origin. See: https://cloud.google.com/cdn/docs/using-ttl-overrides"
  type        = number
  default     = 86400
}

variable "client_ttl" {
  description = "Specifies the maximum allowed TTL for cached content served by this origin. See: https://cloud.google.com/cdn/docs/using-ttl-overrides"
  type        = number
  default     = 3600
}

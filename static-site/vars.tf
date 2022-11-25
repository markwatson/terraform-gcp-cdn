variable "name" {
  type = string
  description = "The name to use for the bucket. If you use a domain name, then you must register the service account email for TF here: https://www.google.com/webmasters/verification/home?hl=en"
}

variable "location" {
  type = string
  default = "US"
  description = "The location to use"
}

variable "admin_members" {
  type = list
  description = "The users to apply the admin policy to"
}
variable "labels" {
  description = "The key is the label name and the value is the label value."
  type        = map(string)
  default     = {}
}

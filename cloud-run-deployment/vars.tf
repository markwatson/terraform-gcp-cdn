variable "name" {
    decription = "The name of the cloud run service"
    type = string
}

variable "location" {
    description = "The region to create the cloud run in."
    type = string
}

variable "project" {
    description = "The project ID to create the resources in."
    type = string
}

variable "build_trigger" {
    description = "Should we enable a CI/CD trigger?"
    type = bool
    default = false
}

variable "build_trigger_options" {
    description = "Options for the CI/CD trigger."
    type = object({
        github_owner = string
        github_name = string
        branch = string
    })
    default = null
}
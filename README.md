# Overview

This repository contains Google Cloud Platform CDN Terraform modules. Google provides a number
of [official Terraform modules](https://registry.terraform.io/search/modules?namespace=GoogleCloudPlatform), which are probably better suited to your needs than these modules. I created these because I wanted a simple way to host websites that scale with traffic, but didn't want
to string together new TF resources for every project.

# Modules

- [cdn](cdn): Module for creating a CDN.
- [cloud-run-public](cloud-run-public): Module for creating a Cloud Run service with a public endpoint.
- [static-site](static-site): Module for creating a static website.

Usually usage will involve creating a CDN, and then using either the static-site or cloud-run-public modules to create a backend for the CDN. If you want to serve the site via Docker, then use Cloud Run. If you instead want to compile the HTML statically and upload to a bucket, then use the static-site module.

For sites with low traffic, you probably want to stick with a single "CDN" module, and then nest multiple sites under it. The CDN module uses a global forwarding rule, which costs around $20/month. You can host multiple sites under a single CDN, which will save cost. For sites with high traffic, bandwidth will quickly consume all your costs, and so there might be cheaper options elsewhere.

The advantage of using this approach is that it dynamically scales, requires no maintenance, and serves with low latency anywhere in the world (well almost anywhere). I also find it much simpler to setup than the alternatives in AWS (CloudFront, S3, Route53, etc).

# Usage

For all modules, you will need to setup the google provider:

```hcl
provider "google" {
  alias   = "gcentral"
  project = "my-awesome-project"
  region  = "us-central1"
  zone    = "us-central1-f"
}
```

This arbitrarily uses use-central1, but you can use any region/zone you want. From here you would pull in each module, and configure as needed. There are examples below of simple setups.

To actually make this work, the easiest way would be to:

- Setup [Google Cloud w/ billing](https://cloud.google.com/).
- Setup [Terraform Cloud](https://cloud.hashicorp.com/products/terraform) to apply the resources (free).
- Buy your domain.
- Create the resources with Terraform Cloud.
- Authorize GCP to access the domain in [webmaster central](https://www.google.com/webmasters/verification/home). If you're using Terraform Cloud, see [this article](https://medium.com/@bitniftee/flash-tutorial-fix-cloud-run-domain-mapping-verification-issues-4dba51151578).
- Update the DNS records on your domain to point at the correct IP address (see the "ip_address" output of the CDN module, or find it in the GCP GUI).

I'd like to publish a full tutorial on this in the future.

## Single Static Site

The example below shows how to configure the CDN with a single static site backed by cloud storage. It doesn't configure DNS on your domain, but you can use the "ip_address" output to configure DNS manually.

```hcl
// Configure the Google Cloud provider
provider "google" {
  alias   = "gcentral"
  project = "my-awesome-project"
  region  = "us-central1"
  zone    = "us-central1-f"
}

// Some configuration variables
locals {
  // This allows service accounts to upload content to the storage bucket.
  // You can add CI/CD here to enable automatic deployments.
  // You should update to your specific setup
  storage_admin_members = [
    // Used for TF to manage the bucket content
    "serviceAccount:terraform@my-awesome-project.iam.gserviceaccount.com",
    // Used for CI/CD to manage the bucket content
    "serviceAccount:github-storage@my-awesome-project.iam.gserviceaccount.com",
    // Maybe you have a group that should have access to manage in the GUI?
    "group:gcp-developers@example.com",
    "group:gcp-devops@example.com"
  ]
  region = "us-central1"
  project = "my-awesome-project"
  bucket_location = "US"
}

// The CDN
module "main-cdn" {
  source = "github.com/markwatson/terraform-gcp-cdn/cdn"
  providers = {
    google = google.gcentral
  }
  name = "main-cdn"
  project = local.project
  default_service = module.example-backend.backend.id
  host_rules = {
    // Note: You can put multiple backends here to host many sites.
    "www.example.com" = module.example-backend.backend.id
  }
}

// Static site
module "example-backend" {
  source = "github.com/markwatson/terraform-gcp-cdn/static-site"
  providers = {
    google = google.gcentral
  }
  location = local.bucket_location
  name = "www.example.com"
  admin_members = local.storage_admin_members
  labels = {
    "type" = "static-site"
  }
}
```

## Single Cloud Run Site

The example below shows how to configure a CloudRun site that sits behind the CDN. While the CloudRun site is configured, it does not configure deployments.

```hcl
// Configure the Google Cloud provider
provider "google" {
  alias   = "gcentral"
  project = "my-awesome-project"
  region  = "us-central1"
  zone    = "us-central1-f"
}

// Some configuration variables
locals {
  region = "us-central1"
  project = "my-awesome-project"
}

// The CDN
module "main-cdn" {
  source = "github.com/markwatson/terraform-gcp-cdn/cdn"
  providers = {
    google = google.gcentral
  }
  name = "main-cdn"
  project = local.project
  default_service = module.example-backend.backend.id
  host_rules = {
    // Note: You can put multiple backends here to host many sites.
    "www.example.com" = module.example-backend.backend.id
  }
}

// CloudRun site
module "example-backend" {
  source = "github.com/markwatson/terraform-gcp-cdn/cloud-run-public"

  providers = {
    google = google.gcentral
  }

  project = local.project
  region = local.region
  name = "example-backend"
  cloudrun_name = "example-backend-api"
}
```

## Multiple Sites

To put multiple sites behind the CDN, you can just pass multiple URL maps to the "host_rules" argument:

```hcl
module "main-cdn" {
  source = "github.com/markwatson/terraform-gcp-cdn/cdn"
  providers = {
    google = google.gcentral
  }
  name = "main-cdn"
  project = local.project
  default_service = module.example-website.backend.id
  host_rules = {
    // Note: You can put multiple backends here to host many sites.
    "www.example.com" = module.example-website.backend.id
    "api.example.com" = module.example-backend-api.backend.id
  }
}
```

You will need to update the DNS for each subdomain to point at the same global IP address. GCP will automatically route the traffic to the correct backend.

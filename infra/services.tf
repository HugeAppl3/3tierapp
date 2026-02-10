locals {
  services = [
    "compute.googleapis.com",      # For Networking/VPC
    "run.googleapis.com",          # For Frontend/Backend
    "sqladmin.googleapis.com",     # For Cloud SQL
    "vpcaccess.googleapis.com",    # For the Serverless Connector
    "secretmanager.googleapis.com", # For secure credentials
    "servicenetworking.googleapis.com" # For Private Service Connect (if needed for Cloud SQL)
  ]
}

resource "google_project_service" "enabled_services" {
  for_each = toset(local.services)
  service  = each.key

  # Set this to false so you don't accidentally break things if you destroy the infra
  disable_on_destroy = false
}
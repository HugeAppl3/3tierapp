# 1. Create the Custom VPC
resource "google_compute_network" "custom_vpc" {
  name                    = "app-vpc"
  auto_create_subnetworks = false # Always set to false for custom control
  routing_mode            = "REGIONAL"
}

# 2. Create a Private Subnet
resource "google_compute_subnetwork" "app_subnet" {
  name          = "app-subnet-us-central1"
  ip_cidr_range = "10.111.11.0/24"
  region        = "us-central1"
  network       = google_compute_network.custom_vpc.id
  
  # Enabling Flow Logs is a security best practice for auditing traffic
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# 3. Firewall Rule: Allow Internal Traffic
# This allows resources within the VPC to communicate with each other.
resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal"
  network = google_compute_network.custom_vpc.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = ["10.111.11.0/24"]
}
# 1. Create the Cloud Router
# This serves as the control plane for your NAT gateway.
resource "google_compute_router" "router" {
  name    = "app-router"
  region  = "us-central1"
  network = google_compute_network.custom_vpc.id

  # Note: No BGP configuration is needed when used specifically for Cloud NAT.
}

# 2. Create the Cloud NAT Gateway
resource "google_compute_router_nat" "nat" {
  name                               = "app-nat-gateway"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  
  # AUTO_ONLY lets Google manage the external IP addresses for the gateway.
  nat_ip_allocate_option             = "AUTO_ONLY"
  
  # This tells the NAT to serve the primary IP range of your subnet.
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY" # Change to "ALL" if you need to audit every connection.
  }
}
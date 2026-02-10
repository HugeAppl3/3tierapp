# 1. Reserve a Global Public IP address
resource "google_compute_global_address" "lb_ip" {
  name = "app-lb-ip"
}

# 1a. Create a Managed SSL Certificate for the LB (using the reserved IP) - Lifecycle with "create_before_destroy" to allow for a seamless swap during updates
resource "google_compute_managed_ssl_certificate" "default" {
  # Add a random suffix or change the name to avoid a name collision 
  # during the "create_before_destroy" phase
  name = "app-cert2" 

  managed {
    domains = ["gcpdemo.hugeapple.com"] # Update to the correct hostname
  }

  lifecycle {
    create_before_destroy = true # CRITICAL: This allows the swap
  }
}

# 2. Create the Serverless NEG for the Backend
resource "google_compute_region_network_endpoint_group" "backend_neg" {
  name                  = "backend-neg"
  network_endpoint_type = "SERVERLESS"
  region                = "us-central1"
  cloud_run {
    service = google_cloud_run_v2_service.backend.name
  }
}

# 3. Create the Backend Service for the LB
resource "google_compute_backend_service" "app_backend" {
  name                  = "app-backend-service"
  protocol              = "HTTP2"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  
  backend {
    group = google_compute_region_network_endpoint_group.backend_neg.id
  }
}

# 4. URL Map (The "Traffic Controller")
resource "google_compute_url_map" "lb_url_map" {
  name            = "app-url-map"
  default_service = google_compute_backend_service.app_backend.id
}

# 5. HTTP and HTTPSProxy and Forwarding Rules
resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "http-proxy"
  url_map = google_compute_url_map.lb_url_map.id
}

resource "google_compute_target_https_proxy" "https_proxy" {
  name             = "https-proxy"
  url_map          = google_compute_url_map.lb_url_map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default.id]
}

# 6. Create a new Forwarding Rule for Port 443
resource "google_compute_global_forwarding_rule" "http_rule" {
  name                  = "http-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_target_http_proxy.http_proxy.id
  ip_address            = google_compute_global_address.lb_ip.id
}
# 6a. Create a new Forwarding Rule for Port 443 
resource "google_compute_global_forwarding_rule" "https_rule" {
  name                  = "https-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "443"
  target                = google_compute_target_https_proxy.https_proxy.id
  ip_address            = google_compute_global_address.lb_ip.id
}

output "load_balancer_ip" {
  value = google_compute_global_address.lb_ip.address
}
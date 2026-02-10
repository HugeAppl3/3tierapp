# 1. THE BRIDGE: Reserve internal IP range for Google Services
# This allocates a block of IPs for managed services like Cloud SQL.
resource "google_compute_global_address" "private_ip_alloc" {
  name          = "private-ip-alloc"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.custom_vpc.id
}

# 2. Establish the Service Networking Connection (VPC Peering)
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.custom_vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
  # CRITICAL: This allows the DB network to "see" your connector 
  deletion_policy = "ABANDON"
}

# This tells the VPC peering to exchange custom routes (like your VPC Connector)
resource "google_compute_network_peering_routes_config" "peering_routes" {
  peering = "servicenetworking-googleapis-com" # This is the standard name for SQL peering
  network = google_compute_network.custom_vpc.name

  import_custom_routes = true
  export_custom_routes = true # CRITICAL: This allows the DB to see your connector
}

# 3. THE VAULT: Private Cloud SQL Instance
resource "google_sql_database_instance" "db_instance" {
  name             = "app-db-instance"
  region           = "us-central1"
  database_version = "POSTGRES_15"
  
  
  # Crucial: The DB cannot be created until the peering bridge is ready
  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = "db-f1-micro" # Cost-effective for practice

    ip_configuration {
      ipv4_enabled                                  = false # Disables Public IP
      private_network                               = google_compute_network.custom_vpc.id
      enable_private_path_for_google_cloud_services = true
    }

    backup_configuration {
      enabled            = true
      start_time         = "04:00"
      location           = "us"
    }
  }
  
  # Set to false for practice so you can easily clean up resources
  deletion_protection = false 
}
# Create the actual database 
resource "google_sql_database" "app_db" {
  name     = "app_db"
  instance = google_sql_database_instance.db_instance.name
}

# Create the user the app is looking for
resource "google_sql_user" "postgres_user" {
  name     = "postgres"
  instance = google_sql_database_instance.db_instance.name
  password = google_secret_manager_secret_version.db_password_val.secret_data
}
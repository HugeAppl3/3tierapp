resource "google_vpc_access_connector" "main_connector" {
  name          = "lab-connector"
  region        = "us-central1"
  ip_cidr_range = "10.8.0.0/28"
  network       = google_compute_network.custom_vpc.name # Use .name here!
}
resource "google_artifact_registry_repository" "app_repo" {
  location      = "us-central1"
  repository_id = "app-repo"
  description   = "Docker repository for 3-tier app images"
  format        = "DOCKER"

  # Optional: Cleanup policy to keep only the 10 most recent images
  #cleanup_policy {
   # id     = "keep-minimum-versions"
    #action = "KEEP"
    #Most_recent_versions {
      #keep_count = 10
    #}
  }

resource "google_cloud_run_service_iam_member" "public_access" {
  location = google_cloud_run_v2_service.backend.location
  service  = google_cloud_run_v2_service.backend.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
resource "google_project_iam_member" "backend_sql_client" {
  project = "tierapp-486801"
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.backend_sa.email}"
}
resource "google_compute_firewall" "allow_sql_from_connector" {
  name    = "allow-sql-from-connector"
  network = "app-vpc" # Ensure this matches your VPC name

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  # Allow the specific range of your lab-connector
  source_ranges = ["10.8.0.0/28"] 
}
resource "google_cloud_run_v2_service" "backend" {
  name     = "backend-api"
  location = "us-central1"
  ingress  = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER" # Only allows traffic from within your VPC and Cloud Load Balancing

  template {
    service_account = google_service_account.backend_sa.email
    # VPC Access configuration
    vpc_access {
        connector = google_vpc_access_connector.main_connector.id
        egress    = "ALL_TRAFFIC" # Routes all outbound traffic through the VPC
      }
    containers {
      image = "us-central1-docker.pkg.dev/tierapp-486801/app-repo/backend:latest"
      
      # Pass the private IP of the Cloud SQL instance as an environment variable to be used by the application to connect to the database
      env {
        name  = "DB_HOST"
        value = google_sql_database_instance.db_instance.private_ip_address
      }
      # Inject the DB password from Secret Manager
      env {
        name = "DB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.db_password.secret_id
            version = "latest"
          }
        }
      }
      env {
        name  = "DB_USER"
        value = "postgres"
      }
      env {
        name  = "DB_NAME"
        value = "app_db"
      }  
        }
      }

      
      
    
  

  # Ensure networking and secrets are ready before deployment (Don't forget to add other dependencies as needed - Private VPC connection, Artifact Registry, etc.)
  
    depends_on = [
    google_vpc_access_connector.main_connector,
    google_secret_manager_secret_version.db_password_val,
    google_artifact_registry_repository.app_repo,
    google_service_networking_connection.private_vpc_connection

  ]
  }  




resource "google_cloud_run_v2_service" "frontend" {
  name     = "frontend-web"
  location = "us-central1"
  ingress  = "INGRESS_TRAFFIC_ALL" # Publicly accessible 

  template {
    # Increase the timeout to 300 seconds (5 minutes) to allow for longer processing times if needed
    timeout = "300s"
    containers {
      image = "us-central1-docker.pkg.dev/tierapp-486801/app-repo/frontend:latest"
      ports {
        container_port = 8080 #Matches the port the application listens on - Nginix dockerfile EXPOSE
      }
    }
  }
}

# Output the public URL of the frontend service
output "frontend_web_url" {
  value       = google_cloud_run_v2_service.frontend.uri
  description = "The public URL where the frontend website can be accessed."
}

# Allow public access to the frontend service
resource "google_cloud_run_service_iam_member" "frontend_public" {
  location = google_cloud_run_v2_service.frontend.location
  service  = google_cloud_run_v2_service.frontend.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

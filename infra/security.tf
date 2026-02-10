# 1. Create a Secret for the Database Password
resource "google_secret_manager_secret" "db_password" {
  secret_id = "db-password"
  
  replication {
    # Use the 'auto' block instead of 'automatic = true'
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_password_val" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = "your-secure-password-here" # In prod, use a variable or random_password resource
}

# 2. Create a Custom Service Account for the Backend
resource "google_service_account" "backend_sa" {
  account_id   = "backend-runner"
  display_name = "Backend Cloud Run Service Account"
}

# 3. Grant Permission: Access the Secret
resource "google_secret_manager_secret_iam_member" "secret_access" {
  secret_id = google_secret_manager_secret.db_password.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.backend_sa.email}"
}

# 4. Grant Permission: Connect to Cloud SQL
resource "google_project_iam_member" "sql_client" {
  project = "tierapp-486801"
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.backend_sa.email}"
}
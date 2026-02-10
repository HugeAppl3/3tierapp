terraform {
  backend "gcs" {
    bucket  = "mm3tier"
    prefix  = "terraform/frontend-state" # DIFFERENT prefix than the main state 
  }
}

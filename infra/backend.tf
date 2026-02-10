terraform {
  backend "gcs" {
    bucket  = "mm3tier"
    prefix  = "terraform/state"
  }
}
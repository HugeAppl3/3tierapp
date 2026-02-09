# 3-Tier Web Application on GCP

## Overview
This project demonstrates a secure, automated 3-tier architecture on Google Cloud Platform using **Cloud Run**, **Cloud SQL**, and **Terraform**.

## Directory Structure
- `/infra`: Terraform configuration files (VPC, Cloud Run, Cloud SQL, IAM).
- `/backend`: API logic (containerized).
- `/frontend`: User interface (containerized).

## Architecture & Security
- **Zero Public Access:** Cloud SQL is provisioned with a Private IP only.
- **VPC Integration:** Cloud Run communicates via a Serverless VPC Access Connector.
- **Secrets Management:** Credentials are never hardcoded; they are managed via GCP Secret Manager.
- **Automation:** Infrastructure is deployed via CI/CD (Cloud Build) triggered by git pushes.

## How to Deploy
1. Ensure the Google Cloud SDK and Terraform are installed.
2. Run `terraform init` and `terraform apply` from the `/infra` directory.

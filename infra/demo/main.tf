provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_project_service" "required" {
  for_each = toset([
    "artifactregistry.googleapis.com",
    "container.googleapis.com",
  ])

  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "portfolio_api" {
  project       = var.project_id
  location      = var.region
  repository_id = var.artifact_registry_repository
  description   = "Docker images for the portfolio API demo"
  format        = "DOCKER"

  depends_on = [google_project_service.required]
}

resource "google_service_account" "gke_nodes" {
  project      = var.project_id
  account_id   = "portfolio-demo-gke-nodes"
  display_name = "Portfolio demo GKE nodes"

  depends_on = [google_project_service.required]
}

resource "google_project_iam_member" "gke_node_roles" {
  for_each = toset([
    "roles/artifactregistry.reader",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer",
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_container_cluster" "portfolio_demo" {
  name     = var.cluster_name
  location = var.zone

  deletion_protection      = false
  remove_default_node_pool = true
  initial_node_count       = 1

  release_channel {
    channel = "REGULAR"
  }

  ip_allocation_policy {}

  resource_labels = {
    app         = "portfolio-api"
    environment = "demo"
    managed-by  = "terraform"
  }

  depends_on = [google_project_service.required]
}

resource "google_container_node_pool" "demo_pool" {
  name       = "demo-pool"
  cluster    = google_container_cluster.portfolio_demo.name
  location   = var.zone
  node_count = var.node_count

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type    = var.machine_type
    disk_size_gb    = var.disk_size_gb
    spot            = var.use_spot_nodes
    service_account = google_service_account.gke_nodes.email

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    labels = {
      app         = "portfolio-api"
      environment = "demo"
    }

    tags = ["portfolio-api-demo"]
  }

  depends_on = [google_project_iam_member.gke_node_roles]
}

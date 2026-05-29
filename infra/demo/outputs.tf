output "cluster_name" {
  description = "GKE demo cluster name."
  value       = google_container_cluster.portfolio_demo.name
}

output "cluster_zone" {
  description = "GKE demo cluster zone."
  value       = var.zone
}

output "artifact_registry_repository_url" {
  description = "Docker repository URL used by the GitHub Actions workflow."
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.portfolio_api.repository_id}"
}

output "get_credentials_command" {
  description = "Command for connecting kubectl to the demo cluster."
  value       = "gcloud container clusters get-credentials ${google_container_cluster.portfolio_demo.name} --zone ${var.zone} --project ${var.project_id}"
}


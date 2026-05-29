variable "project_id" {
  description = "GCP project ID used for the demo infrastructure."
  type        = string
}

variable "region" {
  description = "GCP region for Artifact Registry."
  type        = string
  default     = "me-west1"
}

variable "zone" {
  description = "GCP zone for the GKE demo cluster."
  type        = string
  default     = "me-west1-a"
}

variable "cluster_name" {
  description = "Name of the temporary GKE demo cluster."
  type        = string
  default     = "portfolio-cluster"
}

variable "artifact_registry_repository" {
  description = "Artifact Registry Docker repository name."
  type        = string
  default     = "portfolio-api"
}

variable "node_count" {
  description = "Number of nodes in the demo node pool."
  type        = number
  default     = 1
}

variable "machine_type" {
  description = "Machine type for the demo node pool."
  type        = string
  default     = "e2-small"
}

variable "disk_size_gb" {
  description = "Boot disk size for each demo node."
  type        = number
  default     = 20
}

variable "use_spot_nodes" {
  description = "Use Spot VMs for the demo node pool to reduce cost. Disable if you need more reliability during a live demo."
  type        = bool
  default     = true
}


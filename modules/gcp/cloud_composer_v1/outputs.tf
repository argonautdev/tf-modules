output "composer_env_name" {
  value       = google_composer_environment.composer_env.name
  description = "Name of the Cloud Composer Environment."
}

output "composer_env_id" {
  value       = google_composer_environment.composer_env.id
  description = "ID of Cloud Composer Environment."
}

output "gke_cluster" {
  value       = google_composer_environment.composer_env.config.0.gke_cluster
  description = "Google Kubernetes Engine cluster used to run the Cloud Composer Environment."
}

output "gcs_bucket" {
  value       = google_composer_environment.composer_env.config.0.dag_gcs_prefix
  description = "Google Cloud Storage bucket which hosts DAGs for the Cloud Composer Environment."
}

output "airflow_uri" {
  value       = google_composer_environment.composer_env.config.0.airflow_uri
  description = "URI of the Apache Airflow Web UI hosted within the Cloud Composer Environment."
}
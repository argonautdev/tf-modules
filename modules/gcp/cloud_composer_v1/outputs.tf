output "composer_env_name" {
  value       = module.composer.composer_env_name
  description = "Name of the Cloud Composer Environment."
}

output "composer_env_id" {
  value       = module.composer.composer_env_id
  description = "ID of Cloud Composer Environment."
}

output "gke_cluster" {
  value       = module.composer.gke_cluster
  description = "Google Kubernetes Engine cluster used to run the Cloud Composer Environment."
}

output "gcs_bucket" {
  value       = module.composer.gcs_bucket
  description = "Google Cloud Storage bucket which hosts DAGs for the Cloud Composer Environment."
}

output "airflow_uri" {
  value       = module.composer.airflow_uri
  description = "URI of the Apache Airflow Web UI hosted within the Cloud Composer Environment."
}
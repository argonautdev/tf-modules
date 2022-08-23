output "names" {
  description = "Bucket names."
  value       = module.gcs_bucket.names
}

output "urls" {
  description = "Bucket URL."
  value       = module.gcs_bucket.urls
}

output "names_list" {
  description = "List of bucket names."
  value       = module.gcs_bucket.names_list
}

output "urls_list" {
  description = "List of bucket URLs."
  value       = module.gcs_bucket.urls_list
}
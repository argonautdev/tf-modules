output "buckets" {
  description = "The created storage bucket"
  value       = module.gcs_bucket.buckets
}

output "names" {
  description = "Bucket name."
  value       = module.gcs_bucket.bucket.names
}

output "urls" {
  description = "Bucket URL."
  value       = module.gcs_bucket.bucket.urls
}
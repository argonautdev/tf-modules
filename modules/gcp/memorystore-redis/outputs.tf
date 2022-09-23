output "id" {
  description = "The memorystore instance ID."
  value       = module.memorystore.id
}

output "host" {
  description = "The IP address of the instance."
  value       = module.memorystore.host
}

output "port" {
  description = "The port number of the exposed Redis endpoint."
  value       = module.memorystore.port
}

output "region" {
  description = "The region the instance lives in."
  value       = module.memorystore.region
}

output "current_location_id" {
  description = "The current zone where the Redis endpoint is placed."
  value       = module.memorystore.current_location_id
}

output "persistence_iam_identity" {
  description = "Cloud IAM identity used by import/export operations. Format is 'serviceAccount:'. May change over time"
  value       = module.memorystore.persistence_iam_identity
}

output "auth_string" {
  description = "AUTH String set on the instance. This field will only be populated if auth_enabled is true."
  value       = data.google_redis_instance.export_redis_instance_info.auth_string
  # module.memorystore.auth_string
  sensitive   = false
}

output "server_ca_certs" {
  description = "List of server CA certificates for the instance"
  value       = module.memorystore.server_ca_certs
  sensitive   = false
}
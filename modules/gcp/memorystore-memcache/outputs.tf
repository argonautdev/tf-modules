output "id" {
  description = "The memorystore instance ID."
  value       = module.memcache.id
}

output "region" {
  description = "The region the instance lives in."
  value       = module.memcache.region
}

output "nodes" {
  description = "Data about the memcache nodes"
  value       = module.memcache.nodes
}

output "discovery_endpoint" {
  description = "The memorystore discovery endpoint."
  value       = module.memcache.discovery
}
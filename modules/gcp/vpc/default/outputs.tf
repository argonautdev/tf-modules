output "network" {
  value       = module.vpc
  description = "The created network"
}

output "network_name" {
  value       = module.vpc.network_name
  description = "The name of the VPC being created"
}

output "network_id" {
  value       = module.vpc.network_id
  description = "The ID of the VPC being created"
}

output "network_self_link" {
  value       = module.vpc.network_self_link
  description = "The URI of the VPC being created"
}

output "subnets_names" {
  value       = module.vpc.subnets_names
  description = "The names of the subnets being created"
}

output "subnets_ids" {
  value       = module.vpc.subnets_ids
  description = "The IDs of the subnets being created"
}

output "subnets_ips" {
  value       = module.vpc.subnets_ips
  description = "The IPs and CIDRs of the subnets being created"
}

output "subnets_self_links" {
  value       = module.vpc.subnets_self_links
  description = "The self-links of subnets being created"
}

output "subnets_regions" {
  value       = module.vpc.subnets_regions
  description = "The region where the subnets will be created"
}

output "private_service_access_name" {
  value       = module.private-service-access.google_compute_global_address_name
  description = "The name of the private service access created"
}
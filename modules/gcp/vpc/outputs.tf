output "network" {
  value       = one(module.vpc[*])
  description = "The created network"
}

output "network_name" {
  value       = var.import_resource ? var.network_name : one(module.vpc[*].network_name)
  description = "The name of the VPC being created"
}

output "network_id" {
  value       = one(module.vpc[*].network_id)
  description = "The ID of the VPC being created"
}

output "network_self_link" {
  value       = one(module.vpc[*].network_self_link)
  description = "The URI of the VPC being created"
}

output "subnets_names" {
  value       = one(module.vpc[*].subnets_names)
  description = "The names of the subnets being created"
}

output "subnets_ids" {
  value       = one(module.vpc[*].subnets_ids)
  description = "The IDs of the subnets being created"
}

output "subnets_ips" {
  value       = one(module.vpc[*].subnets_ips)
  description = "The IPs and CIDRs of the subnets being created"
}

output "subnets_self_links" {
  value       = one(module.vpc[*].subnets_self_links)
  description = "The self-links of subnets being created"
}

output "subnets_regions" {
  value       = one(module.vpc[*].subnets_regions)
  description = "The region where the subnets will be created"
}
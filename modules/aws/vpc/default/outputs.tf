output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "default_security_group_id" {
  value = module.vpc.default_security_group_id
}

// IDs of the subnets created in the VPC
output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "database_subnets" {
  value = module.vpc.database_subnets
}

output "elasticache_subnets" {
  value = module.vpc.elasticache_subnets
}

output "private_secondary_subnets" {
  value = module.vpc.private_secondary_subnets
}
output "vpc_id" {
  value = var.is_imported ? var.import_vpc_id : one(module.vpc[*].vpc_id)
}

output "vpc_cidr_block" {
  value = var.is_imported ? var.cidr_block : one(module.vpc[*].vpc_cidr_block)
}

output "default_security_group_id" {
  value = var.is_imported ? var.import_security_group_id : one(module.vpc[*].default_security_group_id)
}

// IDs of the subnets created in the VPC
output "public_subnets" {
  value = var.is_imported ? var.public_subnet_cidr_blocks : one(module.vpc[*].public_subnets)
}

output "private_subnets" {
  value = var.is_imported ? var.private_subnet_cidr_blocks : one(module.vpc[*].private_subnets)
}

output "database_subnets" {
  value = var.is_imported ? var.database_subnet_cidr_blocks : one(module.vpc[*].database_subnets)
}

output "elasticache_subnets" {
  value = var.is_imported ? var.elasticache_subnet_cidr_blocks : one(module.vpc[*].elasticache_subnets)
}

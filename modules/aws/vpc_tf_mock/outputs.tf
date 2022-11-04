output "vpc_id" {
  value = var.import_vpc_id
}

output "vpc_cidr_block" {
  value = var.cidr_block
}

output "default_security_group_id" {
  value = var.import_security_group_id
}

// IDs of the subnets created in the VPC
output "public_subnets" {
  value = var.public_subnet_cidr_blocks
}

output "private_subnets" {
  value = var.private_subnet_cidr_blocks
}

output "database_subnets" {
  value = var.database_subnet_cidr_blocks
}

output "elasticache_subnets" {
  value = var.elasticache_subnet_cidr_blocks
}

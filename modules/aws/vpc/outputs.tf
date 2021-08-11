output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "default_security_group_id" {
  value = module.vpc.default_security_group_id
}

// output "vpc_private_subnet_ids" {
//   value = module.vpc.vpc_private_subnet_ids
// }

// output "vpc_nat_gateway_id" {
//   value = module.vpc.vpc_nat_gateway_id
// }

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "database_subnets" {
  value = module.vpc.database_subnets
}

// output "database_subnets_ids" {
//   value = module.vpc.database_subnets_ids
// }

locals {
  validate_subnets = (
    length(var.vpc.private_subnets) < var.number_of_zones ? (
      file("[Error] you must have at least one private subnet per zone")
      ) : (
      ""
    )
  )

  // select the first n subnets from the list of private subnets, where n is the number of zones
  subnet_ids = slice(var.vpc.private_subnets, 0, var.number_of_zones)
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4"

  name        = var.name
  description = "Complete msk security group"
  vpc_id      = var.vpc.vpc_id

  # ingress

  ingress_with_cidr_blocks = [
    {
      from_port   = 2181
      to_port     = 2181
      protocol    = "tcp"
      description = "Allow inbound Zookeeper plaintext traffic"
      cidr_blocks = var.vpc.vpc_cidr_block
    },
    {
      from_port   = 2182
      to_port     = 2182
      protocol    = "tcp"
      description = "Allow inbound Zookeeper tls traffic"
      cidr_blocks = var.vpc.vpc_cidr_block
    },
  ]
}

module "msk" {
  source  = "cloudposse/msk-apache-kafka-cluster/aws"
  version = "0.8.2"

  zone_id                       = var.zone_id
  security_groups               = [module.security_group.security_group_id, var.vpc.default_security_group_id]
  vpc_id                        = var.vpc.vpc_id
  subnet_ids                    = local.subnet_ids
  allowed_cidr_blocks           = concat([var.vpc.vpc_cidr_block], var.allowed_cidr_blocks)
  associated_security_group_ids = [module.security_group.security_group_id, var.vpc.default_security_group_id]
  kafka_version                 = var.kafka_version
  number_of_broker_nodes        = var.number_of_broker_nodes_per_zone * var.number_of_zones
  broker_instance_type          = var.broker_instance_type

  context = module.this.context
}
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4"

  name        = var.name
  description = "Complete msk security group"
  vpc_id      = var.vpc.vpc_id

  # ingress

  ingress_with_cidr_blocks = [
    {
      from_port   = 9094
      to_port     = 9094
      protocol    = "tcp"
      description = "msk access from within VPC"
      cidr_blocks = var.vpc.vpc_cidr_block
    },
  ]
}

module "msk" {
  source  = "cloudposse/msk-apache-kafka-cluster/aws"
  version = "0.8.2"

  zone_id                = var.zone_id
  security_groups        = [module.security_group.security_group_id]
  vpc_id                 = var.vpc.vpc_id
  subnet_ids             = var.vpc.private_subnets
  allowed_cidr_blocks    = concat([var.vpc.vpc_cidr_block], var.allowed_cidr_blocks)
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.number_of_broker_nodes
  broker_instance_type   = var.broker_instance_type

  context = module.this.context
}
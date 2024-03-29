module "redis" {
  source = "cloudposse/elasticache-redis/aws"
  # version = "v0.40.0"
  version = "v0.48.0"
  // version = "v0.41.2"

  // availability_zones               = var.availability_zones
  // zone_id                          = var.zone_id
  vpc_id                           = var.vpc.vpc_id
  subnets                          = var.vpc.private_subnets
  cluster_size                     = var.cluster_size
  instance_type                    = var.instance_type
  apply_immediately                = true
  automatic_failover_enabled       = false
  engine_version                   = var.engine_version
  family                           = var.family
  at_rest_encryption_enabled       = var.at_rest_encryption_enabled
  transit_encryption_enabled       = var.transit_encryption_enabled
  cloudwatch_metric_alarms_enabled = var.cloudwatch_metric_alarms_enabled
  allow_all_egress = false
  additional_security_group_rules = [
    {
      type                     = "egress"
      from_port                = 0
      to_port                  = 65535
      protocol                 = "-1"
      cidr_blocks              = ["0.0.0.0/0"]
      source_security_group_id = null
      description              = "Allow all outbound traffic"
    },
    {
      type                     = "ingress"
      from_port                = 0
      to_port                  = 65535
      protocol                 = "-1"
      cidr_blocks              = []
      source_security_group_id = var.vpc.default_security_group_id
      description              = "Allow all inbound traffic from trusted Security Groups"
    },
    {
      type        = "ingress"
      from_port   = 0
      to_port     = 6379
      protocol    = "-1"
      cidr_blocks = ["10.0.0.0/8", "172.0.0.0/8", "192.0.0.0/8"]
      source_security_group_id = null
      // self        = null
      description = "Allow connections from within the VPC"
    },
  ]

  parameter = var.parameter

  context = module.this.context
}
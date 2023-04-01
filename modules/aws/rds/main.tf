locals {
  port = var.engine == "postgres" ? 5432 : 3306
}
# *** Installs postgres

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4"

  name        = var.identifier
  description = "Complete ${var.engine} security group"
  vpc_id      = var.vpc.vpc_id

  # ingress
  
  ingress_with_cidr_blocks = var.visibility == "public" ? [
    {
      from_port   = local.port
      to_port     = local.port
      protocol    = "tcp"
      description = "${var.engine} access from within VPC"
      cidr_blocks = var.vpc.vpc_cidr_block
    },
    {
      from_port   = local.port
      to_port     = local.port
      protocol    = "tcp"
      description = "Public ${var.engine} access"
      cidr_blocks = "0.0.0.0/0"
    },
  ] : [
    {
      from_port   = local.port
      to_port     = local.port
      protocol    = "tcp"
      description = "${var.engine} access from within VPC"
      cidr_blocks = var.vpc.vpc_cidr_block
    },
  ]

  tags = var.default_tags
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  # version = "v3.3.0"
  version = "v5.1.1"

  identifier = var.identifier

  db_name                               = var.snapshot_identifier != null ? null: var.name
  allocated_storage                     = var.storage
  engine                                = var.engine
  engine_version                        = var.snapshot_identifier != null ? null: var.engine_version
  major_engine_version                  = var.major_engine_version
  family                                = var.family

  instance_class                        = var.instance_class
  username                              = var.snapshot_identifier != null ? null: var.username
  password                              = var.snapshot_identifier != null ? null: var.password

  snapshot_identifier                   = var.snapshot_identifier 
  
  subnet_ids = var.vpc.database_subnets
  vpc_security_group_ids = [module.security_group.security_group_id]
  create_db_subnet_group = var.create_db_subnet_group
  create_random_password = var.create_random_password
  apply_immediately                     = true
  skip_final_snapshot                   = false
  auto_minor_version_upgrade            = true
  backup_retention_period               = 7
  backup_window                         = "02:21-02:51"
  copy_tags_to_snapshot                 = true
  delete_automated_backups              = false
  deletion_protection                   = false
  license_model                         = var.engine == "postgres" ? "postgresql-license" : ""
  maintenance_window                    = "tue:04:29-tue:04:59"
  
  iops                                  = var.iops
  max_allocated_storage                 = var.max_allocated_storage
  multi_az                              = var.multi_az

  port                                  = local.port
  publicly_accessible                   = var.visibility == "public" ? "true" : "false"
  storage_encrypted                     = var.storage_encrypted
  storage_type                          = var.storage_type

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = 7
  enabled_cloudwatch_logs_exports = var.engine == "postgres" ? ["postgresql", "upgrade"] :  ["general"]
  allow_major_version_upgrade = var.allow_major_version_upgrade
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
}


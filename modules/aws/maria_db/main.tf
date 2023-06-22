locals {
  port = 3306
}
# *** Installs MariaDB

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4"

  name        = var.instance_name
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
  version = "v5.1.1"

  identifier = var.instance_name
  /* Subnets */
  create_db_subnet_group                = var.create_db_subnet_group
  db_subnet_group_name                  = var.db_subnet_group_name
  db_subnet_group_description           = var.db_subnet_group_name
  subnet_ids = var.vpc.database_subnets
  create_random_password = var.create_random_password
  vpc_security_group_ids = [module.security_group.security_group_id]
  allow_major_version_upgrade = var.allow_major_version_upgrade
  db_name                               = var.database_name
  engine                                = var.engine
  engine_version                        = var.engine_version
  
  /*Storage*/
  storage_type                          = var.storage_type
  allocated_storage                     = var.disk_size
  iops                                  = var.iops
  max_allocated_storage                 = var.max_allocated_storage
  /* DB */
  instance_class                        = var.instance_class
  username                              = var.master_username
  password                              = var.master_password

  multi_az                              = var.multi_az
  port                                  = local.port
  publicly_accessible                   = var.visibility == "public" ? "true" : "false"
  
  apply_immediately                     = var.apply_immediately
  skip_final_snapshot                   = var.skip_final_snapshot
  auto_minor_version_upgrade            = var.auto_minor_version_upgrade
  backup_window                         = var.backup_window
  backup_retention_period               = var.backup_retention_period
  maintenance_window                    = var.maintenance_window
  copy_tags_to_snapshot                 = var.copy_tags_to_snapshot
  delete_automated_backups              = var.delete_automated_backups
  deletion_protection                   = var.deletion_protection
  iam_database_authentication_enabled   = var.iam_database_authentication_enabled
  
  /* Monitoring */
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  monitoring_interval                   = var.monitoring_interval
  create_monitoring_role                = var.create_monitoring_role
  monitoring_role_use_name_prefix       = var.monitoring_role_use_name_prefix
  
  /* Parameter group */
  parameters                  = var.parameters
  family = var.family
  
  /* Options group */
  create_db_option_group                = var.create_db_option_group
  major_engine_version                  = var.major_engine_version
  options                               = var.options
  
  /* Performance Insights */
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period
  performance_insights_kms_key_id       = var.performance_insights_kms_key_id
}


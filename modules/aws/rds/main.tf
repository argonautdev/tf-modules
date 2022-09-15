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
  version = "v3.3.0"

  identifier = var.identifier
  /* Subnet group */
  create_db_subnet_group                = var.create_db_subnet_group
  db_subnet_group_name                  = var.db_subnet_group_name
  # db_subnet_group_description           = var.db_subnet_group_name
  # db_subnet_group_use_name_prefix       = var.db_subnet_group_use_name_prefix
  subnet_ids = var.vpc.database_subnets
  
  vpc_security_group_ids = [module.security_group.security_group_id]
  
  name                                  = var.name
  engine                                = var.engine
  engine_version                        = var.engine_version
  
  /*Storage*/
  storage_encrypted                     = var.storage_encrypted
  storage_type                          = var.storage_type
  kms_key_id                            = var.kms_key_id
  allocated_storage                     = var.storage
  iops                                  = var.iops
  max_allocated_storage                 = var.max_allocated_storage
  /* DB */
  instance_class                        = var.instance_class
  username                              = var.username
  password                              = var.password
  multi_az                              = var.multi_az
  port                                  = local.port
  publicly_accessible                   = var.visibility == "public" ? "true" : "false"
  
  snapshot_identifier                   = var.snapshot_identifier
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
  license_model                         = var.engine == "postgres" ? "postgresql-license" : ""
  
  /* Monitoring */
  enabled_cloudwatch_logs_exports = var.engine == "postgres" ? ["postgresql", "upgrade"] :  var.enabled_cloudwatch_logs_exports
  monitoring_interval                   = var.monitoring_interval
  create_monitoring_role                = var.create_monitoring_role
  monitoring_role_name                  = var.monitoring_role_name
  # monitoring_role_description           = var.monitoring_role_description
  
  /* Parameter group */
  parameter_group_name = var.parameter_group_name
  parameter_group_description = var.parameter_group_description
  parameters                  = var.parameters
  family = var.family
  
  /* Options group */
  create_db_option_group                = var.create_db_option_group
  major_engine_version                  = var.major_engine_version
  option_group_name                     = var.option_group_name
  option_group_description              = var.option_group_description
  options                               = var.options
  
  /* Performance Insights */
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period
  performance_insights_kms_key_id       = var.performance_insights_kms_key_id
}


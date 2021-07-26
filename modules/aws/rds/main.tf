module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4"

  name        = var.identifier
  description = "Complete PostgreSQL example security group"
  vpc_id      = var.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = var.vpc.vpc_cidr_block
    },
  ]
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 3.0"

  identifier = var.identifier

  name                                  = var.name
  allocated_storage                     = var.storage
  engine                                = var.engine
  engine_version                        = var.engine_version
  instance_class                        = var.instance_class
  username                              = var.username
  password                              = var.password

  subnet_ids                            = var.vpc.public_subnets
  vpc_security_group_ids                = [module.security_group.security_group_id]

  family                                = var.family
  apply_immediately                     = true
  skip_final_snapshot                   = false
  auto_minor_version_upgrade            = true
  backup_retention_period               = 7
  backup_window                         = "07:21-07:51"
  copy_tags_to_snapshot                 = true
  delete_automated_backups              = true
  deletion_protection                   = true
  iam_database_authentication_enabled   = false
  iops                                  = 0
  license_model                         = "postgresql-license"
  maintenance_window                    = "tue:08:29-tue:08:59"
  max_allocated_storage                 = 1000
  multi_az                              = false
  option_group_name                     = "default:postgres-11"
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  port                                  = 5432
  publicly_accessible                   = true
  storage_encrypted                     = true
  storage_type                          = "gp2"
}
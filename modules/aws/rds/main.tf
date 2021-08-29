# *** Installs postgres

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4"

  name        = var.identifier
  description = "Complete PostgreSQL security group"
  vpc_id      = var.vpc.vpc_id

  # ingress
  
  ingress_with_cidr_blocks = var.visibility == "public" ? [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = var.vpc.vpc_cidr_block
    },
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "Public PostgreSQL access"
      cidr_blocks = "0.0.0.0/0"
    },
  ] : [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = var.vpc.vpc_cidr_block
    },
  ]

  tags = var.default_tags
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 3.0"

  identifier = var.identifier

  name                                  = var.name
  allocated_storage                     = var.storage
  engine                                = var.engine
  engine_version                        = var.engine_version
  major_engine_version                  = var.major_engine_version
  family                                = var.family

  instance_class                        = var.instance_class
  username                              = var.username
  password                              = var.password

  subnet_ids = var.vpc.database_subnets
  vpc_security_group_ids = [module.security_group.security_group_id]

  apply_immediately                     = true
  skip_final_snapshot                   = false
  auto_minor_version_upgrade            = true
  backup_retention_period               = 7
  backup_window                         = "02:21-02:51"
  copy_tags_to_snapshot                 = true
  delete_automated_backups              = false
  deletion_protection                   = false
  iam_database_authentication_enabled   = false
  license_model                         = "postgresql-license"
  maintenance_window                    = "tue:04:29-tue:04:59"
  
  iops                                  = 0
  max_allocated_storage                 = 1000
  multi_az                              = false

  port                                  = 5432
  publicly_accessible                   = var.visibility == "public" ? "true" : "false"
  storage_encrypted                     = true
  storage_type                          = "gp2"

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
}


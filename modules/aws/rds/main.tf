data "terraform_remote_state" "environment" {
  backend "pg" {
    conn_str    = "postgres://{{ .BackendData.Username}}:{{.BackendData.Password}}@{{.BackendData.Host}}/{{.Organization.Name }}"
    schema_name = "tf_{{ .Environment.Name }}"
  }
}

# *** Installs postgres

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4"

  name        = var.identifier
  description = "Complete PostgreSQL example security group"
  vpc_id      = data.terraform_remote_state.environment.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = data.terraform_remote_state.environment.vpc.vpc_cidr_block
    },
  ]

  tags = var.default_tags
}

module "rds_db_subnet_group" {
  source     = "terraform-aws-modules/rds/aws//modules/db_subnet_group"
  name       = var.db_subnet_group_name
  subnet_ids = data.terraform_remote_state.environment.outputs.subnet_id
  version    = "3.3.0"
}

# resource "aws_db_subnet_group" "{{ .RDS.Name }}-db-subnet-{{ .UID }}" {
#   name       = "${var.name} db subnet group"
#   subnet_ids = data.terraform_remote_state.environment.outputs.subnet_id
# }

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
  parameter_group_name                  = "default.${var.engine}${var.engine_version}"
  db_subnet_group_name                  = "${aws_db_subnet_group.{{ .RDS.Name }}-db-subnet-{{ .UID }}.name}"
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
  option_group_name                     = "default:postgres-13"
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  port                                  = 5432
  publicly_accessible                   = true
  storage_encrypted                     = true
  storage_type                          = "gp2"
  vpc_security_group_ids                = [aws_vpc.${var.name}-"{{ .UID }}".id]
}

# resource "aws_db_instance" "{{ .RDS.Name }}" {
#   security_group_names                  = []
# }
##To create any database/cluster the following are mandatory
## 1. SecurityGroup
## 2. VPC & PrivateSubnets
## 3. SubnetGroups
##Other Important Points to Note especially for serverless
##Read the README.md carefully before start working on module

locals {
  port = var.cluster_engine == "aurora-postgresql" ? 5432 : 3306
  name = var.cluster_name
}

module "aurora" {
  source = "terraform-aws-modules/rds-aurora/aws"
  version = "7.1.0"
  name                    = var.cluster_name
  engine                  = var.cluster_engine
  engine_mode             = "provisioned"
  engine_version          = var.engine_version
  instance_class          = var.db_instance_class
  storage_encrypted       = var.storage_encrypted
  database_name           = var.database_name
  master_username         = var.master_username
  create_random_password  = false ##Setting to flase as we want to pass password as input. 
  master_password         = var.master_password
  deletion_protection     = var.deletion_protection
  backup_retention_period = var.backup_retention_period
  create_db_subnet_group  = var.create_db_subnet_group
  vpc_id                  = var.vpc.vpc_id
  subnets                 = var.vpc.database_subnets
  db_parameter_group_name = var.db_parameter_group_name ##Name of the parametergroup associated with DB Instances.
  db_cluster_parameter_group_name = var.db_cluster_parameter_group_name ##Name of the parametergroup associated with DB Instances.
  create_security_group = true
  vpc_security_group_ids = [module.security_group.security_group_id]
  allowed_cidr_blocks   = [var.vpc.vpc_cidr_block]
  monitoring_interval   = var.monitoring_interval ##To enable enhanced monitoring for dbcluster default to "0". Meaning disabled 
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  apply_immediately     = var.apply_immediately
  skip_final_snapshot   = var.skip_final_snapshot   ##By default no finalsnpshot should be taken when deleting the cluster
  copy_tags_to_snapshot = var.copy_tags_to_snapshot ##All the Tags associated with cluster gets copied to snapshots
  
  preferred_backup_window = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window
  instances = var.instances
  /** Autoscaling **/
  autoscaling_enabled = var.autoscaling_enabled
  autoscaling_max_capacity = var.autoscaling_max_capacity ##The Maximum number of reader DB instances to be managed by Application Auto Scaling
  autoscaling_min_capacity = var.autoscaling_min_capacity ##The minimum number of reader DB instances to be managed by Application Auto Scaling
  predefined_metric_type = var.predefined_metric_type
  autoscaling_scale_in_cooldown = var.autoscaling_scale_in_cooldown
  autoscaling_scale_out_cooldown = var.autoscaling_scale_out_cooldown
  autoscaling_target_cpu = var.autoscaling_target_cpu
  autoscaling_target_connections = var.autoscaling_target_connections
  /**Performance Insights **/
  performance_insights_enabled = var.performance_insights_enabled
  performance_insights_kms_key_id = var.performance_insights_kms_key_id
  performance_insights_retention_period = var.performance_insights_retention_period

  publicly_accessible                   = var.visibility == "public" ? "true" : "false"
  
}


resource "aws_db_parameter_group" "auroradb" {
  name        = var.db_parameter_group_name
  family      = var.db_parameter_group_family
  description = var.db_parameter_group_name
  # tags        = var.default_tags
  dynamic "parameter" {
    for_each = var.db_parameter_group_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", null)
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_rds_cluster_parameter_group" "auroradb-cluster" {
  name        = var.db_cluster_parameter_group_name
  family      = var.db_parameter_group_family
  description = var.db_cluster_parameter_group_name
  # tags        = var.default_tags
  dynamic "parameter" {
    for_each = var.db_cluster_parameter_group_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", null)
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}



module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4"

  name        = var.cluster_name
  description = "Complete ${var.cluster_engine} security group"
  vpc_id      = var.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = var.visibility == "public" ? [
    {
      from_port   = local.port
      to_port     = local.port
      protocol    = "tcp"
      description = "${var.cluster_engine} access from within VPC"
      cidr_blocks = var.vpc.vpc_cidr_block
    },
    {
      from_port   = local.port
      to_port     = local.port
      protocol    = "tcp"
      description = "Public ${var.cluster_engine} access"
      cidr_blocks = "0.0.0.0/0"
    },
  ] : [
    {
      from_port   = local.port
      to_port     = local.port
      protocol    = "tcp"
      description = "${var.cluster_engine} access from within VPC"
      cidr_blocks = var.vpc.vpc_cidr_block
    },
  ]

  tags = var.default_tags
}
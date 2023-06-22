##To create any database/cluster the following are mandatory
## 1. SecurityGroup
## 2. VPC & PrivateSubnets
## 3. SubnetGroups
##Other Important Points to Note especially for serverless
## 1. No Backup/Maintaince window, We can select Backup Retention though
## 2. No Maintaince window.


# resource "aws_rds_cluster_parameter_group" "auroradb-cluster" {
#   name        = var.db_cluster_parameter_group_name
#   family      = var.db_parameter_group_family
#   description = var.db_cluster_parameter_group_name
#   # tags        = var.default_tags
#   dynamic "parameter" {
#     for_each = var.db_cluster_parameter_group_parameters
#     content {
#       name         = parameter.value.name
#       value        = parameter.value.value
#       apply_method = lookup(parameter.value, "apply_method", null)
#     }
#   }
#   lifecycle {
#     create_before_destroy = true
#   }
# }


module "aurora_cluster" {
  source = "terraform-aws-modules/rds-aurora/aws"
  version  = "7.5.1"
  name                    = var.cluster_name
  engine                  = var.cluster_engine
  engine_mode             = "serverless"
  engine_version          = var.engine_version
  storage_encrypted       = var.storage_encrypted
  database_name           = var.database_name
  master_username         = var.master_username
  master_password         = var.master_password
  deletion_protection     = var.deletion_protection
  backup_retention_period = var.backup_retention_period
  create_db_subnet_group  = var.create_db_subnet_group
  db_subnet_group_name    = var.db_subnet_group_name
  subnets                 = var.vpc.database_subnets
  create_db_cluster_parameter_group = var.create_db_cluster_parameter_group
  db_cluster_parameter_group_family = var.db_cluster_parameter_group_family
  db_cluster_parameter_group_parameters = var.db_cluster_parameter_group_parameters
  vpc_id                  = var.vpc.vpc_id
  create_random_password  = var.create_random_password
  allow_major_version_upgrade = var.allow_major_version_upgrade
  //* creating security group and allowing from vpc cidr block
  create_security_group = true
  allowed_cidr_blocks   = [var.vpc.vpc_cidr_block]

  apply_immediately     = var.apply_immediately
  skip_final_snapshot   = var.skip_final_snapshot   ##By default no finalsnpshot should be taken when deleting the cluster
  copy_tags_to_snapshot = var.copy_tags_to_snapshot ##All the Tags associated with cluster gets copied to snapshots

  scaling_configuration = {
    auto_pause               = true
    min_capacity             = var.cluster_min_capacity
    max_capacity             = var.cluster_max_capacity
    seconds_until_auto_pause = 300
    timeout_action           = "ForceApplyCapacityChange"
  }
}
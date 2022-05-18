##To create any database/cluster the following are mandatory
## 1. SecurityGroup
## 2. VPC & PrivateSubnets
## 3. SubnetGroups
##Other Important Points to Note especially for serverless
##Read the README.md carefully before start working on module


module "aurora" {
  source = "terraform-aws-modules/rds-aurora/aws"

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
  
  create_security_group = true
  allowed_cidr_blocks   = [var.vpc.vpc_cidr_block]
  monitoring_interval   = var.monitoring_interval ##To enable enhanced monitoring for dbcluster default to "0". Meaning disabled 

  apply_immediately     = var.apply_immediately
  skip_final_snapshot   = var.skip_final_snapshot   ##By default no finalsnpshot should be taken when deleting the cluster
  copy_tags_to_snapshot = var.copy_tags_to_snapshot ##All the Tags associated with cluster gets copied to snapshots
  
  preferred_backup_window = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window
  instances = var.instances
}
variable "default_tags" {
  description = "Default Tags"
  type        = map(string)
}

variable "aws_region" {
  description = "aws region"
  type        = string
}

variable "storage_encrypted" {
  description = "Specifies whether the DB cluster storage is encrypted. The default is `true`"
  type        = bool
  default     = true
}

variable "cluster_engine" {
  description = "The name of the database engine to be used for this DB cluster. Valid Values: `aurora-mysql`, `aurora-postgresql`"
  type        = string
}

variable "cluster_name" {
  description = "The name of the database cluster"
  type        = string
}

variable "engine_version" {
  description = "The database engine version. Updating this argument results in an outage"
  type        = string
}

variable "database_name" {
  description = "Name for an automatically created database on cluster creation"
  type        = string
}

variable "master_username" {
  description = "Username for the master DB user"
  type        = string
}

variable "master_password" {
  description = "Password for the master DB user. Note - when specifying a value here, 'create_random_password' should be set to `false`"
  type        = string
  sensitive   = true
}

variable "backup_retention_period" {
  description = "The days to retain backups for. Default `7`"
  type        = number
  default     = 7
}

# aws_db_subnet_group
variable "create_db_subnet_group" {
  description = "Determines whether to create the database subnet group or use existing"
  type        = bool
  default     = true
}


variable "security_group_egress_rules" {
  description = "A map of security group egress rule defintions to add to the security group created"
  type        = map(any)
  default     = {}
}

variable "vpc" {
  description = "All vpc info"
  type = object({
    name                      = string
    vpc_id                    = string
    public_subnets            = list(string)
    private_subnets           = list(string)
    database_subnets          = list(string)
    default_security_group_id = string
    vpc_cidr_block            = string
  })
}

variable "apply_immediately" {
  description = "Specifies whether any cluster modifications are applied immediately, or during the next maintenance window. Default is `false`"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Determines whether a final snapshot is created before the cluster is deleted. If true is specified, no snapshot is created"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to `true`. The default is `false`"
  type        = bool
  default     = false
}

variable "copy_tags_to_snapshot" {
  description = "Copy all Cluster `tags` to snapshots"
  type        = bool
  default     = true
}

variable "monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for instances. Set to `0` to disble. Default is `0`"
  type        = number
  default     = 0
}

# aws_rds_cluster_instances
variable "instances" {
  description = "Map of cluster instances and any specific/overriding attributes to be created"
  type        = any
  default     = {}
}

variable "db_instance_class" {
  description = "Instance type to use at master instance. Note: if `autoscaling_enabled` is `true`, this will be the same instance class used on instances created by autoscaling"
  type        = string
}

variable "preferred_backup_window" {
  description = "The daily time range during which automated backups are created if automated backups are enabled using the `backup_retention_period` parameter. Time in UTC"
  type        = string
  default     = "02:00-03:00"
}

variable "preferred_maintenance_window" {
  description = "The weekly time range during which system maintenance can occur, in (UTC)"
  type        = string
  default     = "sun:05:00-sun:06:00"
}
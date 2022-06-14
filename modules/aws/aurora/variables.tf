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
  description = "The days to retain backups for. Default `9`"
  type        = number
  default     = 9
}

# aws_db_subnet_group
variable "create_db_subnet_group" {
  # TODO
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
  default     = true
}

variable "skip_final_snapshot" {
  description = "Determines whether a final snapshot is created before the cluster is deleted. If true is specified, no snapshot is created"
  type        = bool
  default     = false
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

/** Monitoring and logging **/
variable "monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for instances. Set to `0` to disble. Default is `60`. Valid Values: 0, 1, 5, 10, 15, 30, 60"
  type        = number
  default     = 60
}

variable "enabled_cloudwatch_logs_exports" {
  description = "Set of log types to export to cloudwatch. If omitted, no logs will be exported. The following log types are supported: `audit`, `error`, `general`, `slowquery`, `postgresql`"
  type        = list(string)
  default     = ["postgresql"]
  # default     = ["audit", "error", "general", "slowquery"]
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
  default     = "tue:05:00-tue:06:00"
}

variable "db_parameter_group_name" {
  description = "The name of the DB parameter group to associate with instances"
  type        = string
  default     = null
}

variable "db_parameter_group_family" {
  description = "The parameter group family to associate with the DB parameter group"
  type        = string
  default     = "aurora-postgresql13"
}

variable "db_parameter_group_parameters" {
  description = "The parameters associated with the DB parameter group"
  type = list(object({
    name  = string
    value = string
  }))
  default     = []
}

variable "visibility" {
  description = "Visibility of the rds instance"
  default = "private"
  type        = string
}

variable "db_cluster_parameter_group_name" {
  description = "The name of the DB parameter group to associate with the cluster"
  type        = string
  default     = null
}

variable "db_cluster_parameter_group_parameters" {
  description = "The parameters associated with the DB cluster parameter group"
  type = list(object({
    name  = string
    value = string
  }))
  default     = []
}

# aws_appautoscaling_*
variable "autoscaling_enabled" {
  description = "Determines whether autoscaling of the cluster read replicas is enabled"
  type        = bool
  default     = true
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of read replicas permitted when autoscaling is enabled. Value should not be greater than `15`"
  type        = number
  default     = 10
}

variable "autoscaling_min_capacity" {
  description = "Minimum number of read replicas permitted when autoscaling is enabled"
  type        = number
  default     = 0
}

variable "predefined_metric_type" {
  description = "The metric type to scale on. Valid values are `RDSReaderAverageCPUUtilization` and `RDSReaderAverageDatabaseConnections`"
  type        = string
  default     = "RDSReaderAverageCPUUtilization"
}

##Scalein: A scale-in activity reduces the number of Aurora Replicas in your Aurora DB cluster
variable "autoscaling_scale_in_cooldown" {
  description = "Cooldown in seconds before allowing further scaling operations after a scale in"
  type        = number
  default     = 300
}

##Scaleout: A scale-out activity increases the number of Aurora Replicas in your Aurora DB cluster.
variable "autoscaling_scale_out_cooldown" {
  description = "Cooldown in seconds before allowing further scaling operations after a scale out"
  type        = number
  default     = 300
}

variable "autoscaling_target_cpu" {
  description = "CPU threshold which will initiate autoscaling"
  type        = number
  default     = 70
}

variable "autoscaling_target_connections" {
  description = "Average number of connections threshold which will initiate autoscaling. Default value is 70% of db.r4/r5/r6g.large's default max_connections"
  type        = number
  default     = 700
}

/** Performance Insights **/
variable "performance_insights_enabled" {
  description = "Specifies whether Performance Insights is enabled or not"
  type        = bool
  default     = false
}

variable "performance_insights_kms_key_id" {
  description = "The ARN for the KMS key to encrypt Performance Insights data"
  type        = string
  default     = null
}

variable "performance_insights_retention_period" {
  description = "Amount of time in days to retain Performance Insights data. Either 7 (7 days) or 731 (2 years)"
  type        = number
  default     = null
}
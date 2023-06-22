variable "default_tags" {
  description = "Default Tags"
  type        = map(string)
  default     = {}
}

variable "aws_region" {
  description = "aws region"
  type        = string
  default = ""
}

variable "storage_encrypted" {
  description = "Specifies whether the DB cluster storage is encrypted. The default is `true`"
  type        = bool
  default     = true
}

/* If You want to Pass custom KMS key for storage encryption use the following Parameter */
variable "kms_key_id" {
  description = "The ARN for the KMS encryption key. When specifying `kms_key_id`, `storage_encrypted` needs to be set to `true`"
  type        = string
  default     = null
}


variable "cluster_engine" {
  description = "The name of the database engine to be used for this DB cluster. Valid Values: `aurora-mysql`, `aurora-postgresql`"
  type        = string
  default     = "aurora-mysql"
  validation {
    condition     = var.cluster_engine == "aurora-mysql" || var.cluster_engine == "aurora-postgresql"  
    error_message = "The value choosen is not in the list of ( aurora-mysql, aurora-postgresql )."
  }
}

variable "cluster_name" {
  description = "The name of the database cluster"
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

variable "create_random_password" {
  description = "Determines whether to create random password for RDS primary cluster"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "The days to retain backups for. Default `9`"
  type        = number
  default     = 9
}

# aws_db_subnet_group
variable "create_db_subnet_group" {
  description = "Determines whether to create the database subnet group or use existing"
  type        = bool
  default     = false
}

variable "db_subnet_group_name" {
  description = "The name of the subnet group name (existing or created)"
  type        = string
  default     = ""
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
  default=null
}


variable "enabled_cloudwatch_logs_exports" {
  description = "Set of log types to export to cloudwatch. If omitted, no logs will be exported. The following log types are supported: `audit`, `error`, `general`, `slowquery`, `postgresql`"
  type        = list(string)
  default     = ["audit", "error", "general", "slowquery"]
}

################################################################################
# Cluster Parameter Group
################################################################################

variable "create_db_cluster_parameter_group" {
  description = "Determines whether a cluster parameter should be created or use existing"
  type        = bool
  default     = true
}

variable "db_cluster_parameter_group_family" {
  description = "The family of the DB cluster parameter group"
  type        = string
  default     = "aurora-postgresql13"
}

variable "engine_version" {
  description = "The database engine version. Updating this argument results in an outage"
  type        = string
  default     = "13.9"
}

variable "db_cluster_parameter_group_parameters" {
  description = "A list of DB cluster parameters to apply. Note that parameters may differ from a family to an other"
  type        = list(map(string))
  default     = []
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

//for valid values of mysql, postgresql ACU see the following docs: https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_ModifyCurrentDBClusterCapacity.html
variable "cluster_min_capacity" {
  description = "Min cluster ACU"
  type        = number
  default     = 2
}

variable "cluster_max_capacity" {
  description = "Max cluster ACU"
  type        = number
  default     = 16
}

variable "allow_major_version_upgrade" {
  description = "Enable to allow major engine version upgrades when changing engine versions. Defaults to `false`"
  type        = bool
  default     = true
}
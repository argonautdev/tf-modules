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

/* If You want to Pass custom KMS key for storage encryption use the following Parameter */
variable "kms_key_id" {
  description = "The ARN for the KMS encryption key. When specifying `kms_key_id`, `storage_encrypted` needs to be set to `true`"
  type        = string
  default     = null
}


variable "cluster_engine" {
  description = "The name of the database engine to be used for this DB cluster. Valid Values: `aurora-mysql`, `aurora-postgresql`"
  type        = string
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

variable "backup_retention_period" {
  description = "The days to retain backups for. Default `9`"
  type        = number
  default     = 9
}

# aws_db_subnet_group
variable "create_db_subnet_group" {
  description = "Determines whether to create the database subnet group or use existing"
  type        = bool
  default     = true
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

/* DBClusterParametergroup */
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


/*IAM Authentication for DB*/
variable "iam_database_authentication_enabled" {
  description = "Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled"
  type        = bool
  default     = true
}

variable "db_parameter_group_family" {
  description = "The parameter group family to associate with the DB parameter group"
  type        = string
  default     = "aurora-postgresql10"
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

variable "cluster_min_capacity" {
  description = "Min cluster ACU"
  type        = number
}

variable "cluster_max_capacity" {
  description = "Max cluster ACU"
  type        = number
}
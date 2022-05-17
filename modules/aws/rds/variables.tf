variable "aws_region" {
  description = "aws region"
  type        = string
}

variable "storage" {
  description = "Storage capacity in GB"
  type        = number
}

variable "family" {
  description = "The database family to use"
  default = "postgres13"
  type        = string
}

variable "engine" {
  description = "The database engine to use"
  default = "postgres"
  type        = string
}

variable "major_engine_version" {
  description = "The major engine version to use"
  default = "postgres13"
  type        = string
}

variable "engine_version" {
  description = "The engine version to use"
  default = "13.3"
  type        = string
}

variable "instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
}

variable "username" {
  description = "Username for the master DB user"
  default = "postgres"
  type        = string
}

variable "password" {
  description = "Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file"
  type        = string
}

variable "default_tags" {
  description = "Default Tags"
  type = map(string)
}

variable "name" {
  description = "Name of the database"
  type        = string
}

variable "identifier" {
  description = "Identifier of the RDS instance"
  type        = string
}

variable "visibility" {
  description = "Visibility of the rds instance"
  default = "private"
  type        = string
}

variable "snapshot_identifier" {
  description = "Specifies whether or not to create this database from a snapshot. This correlates to the snapshot ID you'd find in the RDS console, e.g: rds:production-2015-06-26-06-05."
  type        = string
  default     = null
}

variable "storage_encrypted" {
  description = "Encrypt data at rest"
  type        = bool
  default     = true
}

variable "storage_type" {
  description = "Storage type"
  type        = string
  default     = "gp2"
}

variable "multi_az" {
  description = "Enable multi az"
  type        = bool
  default     = false
}

variable "max_allocated_storage" {
  description = "Max allocated storage for db, in GB"
  type        = number
  default     = 1000
}

variable "iops" {
  description = "Provisioned IOPS"
  type        = number
  default     = 0
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
  default     = true
}

variable "monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for instances. Set to `0` to disble. Default is `0`"
  type        = number
  default     = 0
}


variable "vpc" {
  description = "All vpc info"
  type = object({
    name = string
    vpc_id   = string
    public_subnets = list(string)
    private_subnets = list(string)
    database_subnets = list(string)
    default_security_group_id = string
    vpc_cidr_block = string
  })
}

variable "cluster_min_capacity" {
  description = "Minimum Aurora capacity unit ( ACU )"
  type = number
}

variable "cluster_max_capacity" {
  description = "Maximum Aurora capacity unit ( ACU )"
  type = number
}
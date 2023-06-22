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
  default = "13.9"
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
  default = null
}

variable "default_tags" {
  description = "Default Tags"
  type = map(string)
}

variable "name" {
  description = "Name of the database"
  type        = string
  default = null
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
  default     = 10000
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

# DB subnet group
variable "create_db_subnet_group" {
  description = "Whether to create a database subnet group"
  type        = bool
  default     = true
}

variable "create_random_password" {
  description = "Whether to create random password for RDS primary cluster"
  type        = bool
  default     = false
}

variable "allow_major_version_upgrade" {
  description = "Indicates that major version upgrades are allowed. Changing this parameter does not result in an outage and the change is asynchronously applied as soon as possible"
  type        = bool
  default     = true
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

variable "iam_database_authentication_enabled" {
  description = "Specifies whether or not the mappings of AWS Identity and Access Management (IAM) accounts to database accounts are enabled"
  type        = bool
  default     = true
}

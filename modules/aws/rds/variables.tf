variable "aws_region" {
  description = "aws region"
  type        = string
}

variable "db_subnet_group_name" {
  description = "Name for the db subnet group"
  type        = string
}

variable "storage" {
  description = "Storage capacity in GB"
  type        = number
}

variable "engine" {
  description = "The database engine to use"
  type        = string
}

variable "engine_version" {
  description = "The engine version to use"
  type        = string
}

variable "instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
}

variable "username" {
  description = "Username for the master DB user"
  type        = string
}

variable "password" {
  description = "Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file"
  type        = string
}

variable "default_tags" {
  description = "Default Tags"
  type        = map(string)
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
  type        = string
}

variable "vpc" {
  description = "All vpc info"
  type = object({
    name = string
    id   = string
    public_subnets = list(string)
    private_subnets = list(string)
    database_subnets_cidr_blocks = list(string)
    default_security_group_id = string
  })
}

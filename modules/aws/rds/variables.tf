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

variable "project_id" {
  description = "The project ID to manage the Cloud SQL resources"
  type        = string
}

// required
variable "region" {
  description = "The region of the Cloud SQL resources"
  type        = string
  default     = "us-central1"
}


variable "name" {
  type        = string
  description = "The name of the Cloud SQL resources"
}

// required
// Available Version for Different Engines is listed below.
// POSTGRESQL: POSTGRES_9_6,POSTGRES_10, POSTGRES_11, POSTGRES_12, POSTGRES_13, POSTGRES_14
variable "database_version" {
  description = "The database version to use"
  type        = string
  default    = "POSTGRES_12"
}

// DB Connectivity Type //
variable "db_connectivity_type" {
  description = "Type of connectivity to be used. Valid values 'public' and 'private'"
  type        = string
  default     = "private"
}

variable "vpc_network_name" {
  description = "The VPC Network name"
  type        = string
}

variable "private_service_access_name" {
  description = "The private service access name"
  type        = string
}


/* When we use want to use private DB we should actually reservice /16 Internal IP for service provider */ 
/* The Service provider then create subnet on their end and establish peering with our vpc and the good vpc */
/* Note: What ever the IP we reserve here and can't be used with subnetwork or with secondary ranges anymore */
variable "address" {
  description = "internal cidrblock with in the VPC to use by service provider VPC"
  type        = string
  default     = ""
}

variable "prefix_length" {
  description = "Prefix length of the IP range reserved for Cloud SQL instances"
  type        = number
  default     = 16
}


// Master
##For InstanceType
## Ref: https://cloud.google.com/sql/docs/mysql/create-instance?authuser=1#machine-types 
variable "db_compute_instance_size" {
  description = "The instance type  master instance."
  type        = string
}

variable "zone" {
  description = "The zone for the master instance, it should be something like: `us-east4-a`, `us-east4-b`."
  type        = string
}

//About Activation_Policy
//The activation policy specifies when the instance is activated; it is applicable only when the instance state is RUNNABLE. 
//Valid values: 
// 1. ALWAYS: The instance is on, and remains so even in the absence of connection requests. 
// 2. NEVER: The instance is off; it is not activated, even if a connection request arrives. 
// 3. ON_DEMAND: First Generation instances only. The instance responds to incoming requests, and turns itself off when not in use. Instances with PER_USE pricing turn off after 15 minutes of inactivity. Instances with PER_PACKAGE pricing turn off after 12 hours of inactivity.

variable "activation_policy" {
  description = "The activation policy for the master instance. Can be either `ALWAYS`, `NEVER` or `ON_DEMAND`."
  type        = string
  default     = "ALWAYS"
}

// By Default HA ( i.e Multi-AZ enabled)
variable "availability_type" {
  description = "The availability type for the master instance. Can be either `REGIONAL` or `ZONAL`."
  type        = string
  default     = "ZONAL"
}

variable "disk_autoresize" {
  description = "Configuration to increase storage size"
  type        = bool
  default     = true
}

// '0' Meaning That there is no hard limit on db size growing. it can grow up to 64TB  
variable "disk_autoresize_limit" {
  description = "The maximum size to which storage can be auto increased."
  type        = number
  default     = 0
}


//Keeping Minimum 20 GB
variable "disk_size" {
  description = "The disk size for the master instance"
  type        = number
  default     = 20
}

variable "disk_type" {
  description = "The disk type for the master instance."
  type        = string
  default     = "PD_SSD"
}

variable "pricing_plan" {
  description = "The pricing plan for the master instance."
  type        = string
  default     = "PER_USE"
}

variable "maintenance_window_day" {
  description = "The day of week (1-7) for the master instance maintenance."
  type        = number
  default     = 1
}

variable "maintenance_window_hour" {
  description = "The hour of day (0-23) maintenance window for the master instance maintenance."
  type        = number
  default     = 23
}

variable "maintenance_window_update_track" {
  description = "The update track of maintenance window for the master instance maintenance. Can be either `canary` or `stable`."
  type        = string
  default     = "canary"
}

variable "database_flags" {
  description = "List of Cloud SQL flags that are applied to the database server. See [more details](https://cloud.google.com/sql/docs/mysql/flags)"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}


variable "user_labels" {
  type        = map(string)
  default     = {}
  description = "The key/value labels for the master instances."
}

variable "default_labels" {
  type        = map(string)
  default     = {}
  description = "The key/value labels for the master instances."
}

/* Backup Configuration */

variable "point_in_time_recovery_enabled" {
  description = "True if Point-in-time recovery is enabled."
  type = bool
  default = true
}

variable "binary_log_enabled" {
    default = true
    type = bool
    description = "Bydefault enabling this feature. This allows us to work with poin in time recovery. "
}

variable "enabled" {
    default = true
    description = "Whether or not backups should be enabled."
}

variable "start_time" {
    type = string
    default = ""
    description = "four hours window for daily automated backups"
}

/* If it's Multiple region it only supports following */
/* us, eu, asia */
variable "location" {
    type = string
    description = "backups can be stored in multi-region for DR purpose. can be stored in same region itself."
}

/* Automated Backups can be retained for 365 days */
variable "retained_backups" {
    type = number
    description = "How many number of days that automated backups should be retained. valid values between 7 to 365"
    default = 14
}

variable "transaction_log_retention_days" {
    type = number
    description = "How many number of days that transaction logs should be retained. Must be between 1 and 7"
    default = 7
}

variable "retention_unit" {
    type = string
    description = "The unit that 'retained_backups' represents. Defaults to COUNT"
    default = "COUNT"
}

/* IP Configuration */

/* If connectivity == private */
variable "ipv4_enabled" {
   type = bool
   description = "set to true, if you would want to create public sql instance"
   default = false
}

/* Whitlist IP address if type is public */
/* format  = list(object({ name = string, value = string })) */
/* name = A name for this whitelist entry */
/* value = A CIDR notation IPv4 or IPv6 address that is allowed to access this instance. */
variable "authorized_networks" {
    default = []
    description = "whitelist entrys"
} 

variable "require_ssl" {
    default = false
    description = "Whether SSL connections over Public IP are enforced or not."
}

// Read Replicas
variable "read_replicas" {
  description = "List of read replicas to create. Encryption key is required for replica in different region. For replica in same region as master set encryption_key_name = null"
  type = list(object({
    name                  = string
    tier                  = string
    zone                  = string
    disk_type             = string
    disk_autoresize       = bool
    disk_autoresize_limit = number
    disk_size             = string
    user_labels           = map(string)
    database_flags = list(object({
      name  = string
      value = string
    }))
    encryption_key_name = string
  }))
  default = []
}

variable "read_replica_name_suffix" {
  description = "The optional suffix to add to the read instance name"
  type        = string
  default     = ""
}

variable "db_name" {
  description = "The name of the default database to create"
  type        = string
}

variable "db_charset" {
  description = "The charset for the default database"
  type        = string
  default     = ""
}

variable "db_collation" {
  description = "The collation for the default database. Example: 'utf8_general_ci'"
  type        = string
  default     = ""
}

variable "additional_databases" {
  description = "A list of databases to be created in your cluster"
  type = list(object({
    name      = string
    charset   = string
    collation = string
  }))
  default = []
}

variable "user_name" {
  description = "The name of the default user"
  type        = string
}

variable "user_host" {
  description = "The host for the default user"
  type        = string
  default     = "%"
}

variable "user_password" {
  description = "The password for the default user. If not set, a random one will be generated and available in the generated_user_password output variable."
  type        = string
}

variable "additional_users" {
  description = "A list of users to be created in your cluster"
  type        = list(map(any))
  default     = []
}

variable "create_timeout" {
  description = "The optional timout that is applied to limit long database creates."
  type        = string
  default     = "10m"
}

variable "update_timeout" {
  description = "The optional timout that is applied to limit long database updates."
  type        = string
  default     = "10m"
}

variable "delete_timeout" {
  description = "The optional timout that is applied to limit long database deletes."
  type        = string
  default     = "10m"
}

variable "encryption_key_name" {
  description = "The full path to the encryption key used for the CMEK disk encryption"
  type        = string
  default     = null
}

variable "module_depends_on" {
  description = "List of modules or resources this module depends on."
  type        = list(any)
  default     = []
}

variable "deletion_protection" {
  description = "Used to block Terraform from deleting a SQL Instance."
  type        = bool
  default     = false
}

variable "read_replica_deletion_protection" {
  description = "Used to block Terraform from deleting replica SQL Instances."
  type        = bool
  default     = false
}

variable "enable_default_db" {
  description = "Enable or disable the creation of the default database"
  type        = bool
  default     = true
}

variable "enable_default_user" {
  description = "Enable or disable the creation of the default user"
  type        = bool
  default     = true
}

//Query Insights ( a.k.a Performance Insights )
variable "insights_config" {
  description = "The insights_config settings for the database."
  type = object({
    query_string_length     = number
    record_application_tags = bool
    record_client_address   = bool
  })
  default = {
    query_string_length     = null
    record_application_tags = true
    record_client_address   = true
  }
}


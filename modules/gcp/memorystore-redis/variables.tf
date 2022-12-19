variable "project_id" {
  description = "The project ID to manage the Cloud SQL resources"
  type        = string
}

// required
variable "region" {
  description = "The region of the Cloud SQL resources"
  type        = string
  default     = "us-east4"
}

variable "name" {
  description = "The ID of the instance or a fully qualified identifier for the instance."
  type        = string
}

variable "vpc_network_name" {
  description = "The VPC Network name"
  type        = string
  default = ""
}

## Comparision between tiers ( https://cloud.google.com/memorystore/docs/redis/redis-tiers )
variable "tier" {
  description = "The service tier of the instance. https://cloud.google.com/memorystore/docs/redis/reference/rest/v1/projects.locations.instances#Tier"
  type        = string
  default     = "BASIC"
  
  validation {
    condition     = var.tier == "BASIC" || var.tier == "STANDARD_HA" 
    error_message = "The value choosen is not in the list of ( BASIC, STANDARD_HA )."
  }
}

##Maximum range Size in GB is 300
variable "memory_size_gb" {
  description = "Redis memory size in GiB. Defaulted to 1 GiB"
  type        = number
  default     = 1
}

##Valid only when replica enabled
variable "replica_count" {
  description = "The number of replicas. Valid only when 'READ_REPLICAS_DISABLED' Disabled"
  type        = number
  default     = null
}

variable "read_replicas_mode" {
  description = "Read replicas mode. https://cloud.google.com/memorystore/docs/redis/reference/rest/v1/projects.locations.instances#readreplicasmode "
  type        = string
  default     = "READ_REPLICAS_DISABLED"
  
  validation {
    condition     = var.read_replicas_mode == "READ_REPLICAS_DISABLED" || var.read_replicas_mode == "READ_REPLICAS_ENABLED"
    error_message = "The value choosen is not in the list of ( BASIC, STANDARD_HA )."
  }
}

variable "location_id" {
  description = "The zone where the instance will be provisioned. If not provided, the service will choose a zone for the instance. For STANDARD_HA tier, instances will be created across two zones for protection against zonal failures. If [alternativeLocationId] is also provided, it must be different from [locationId]."
  type        = string
  default     = null
}

variable "alternative_location_id" {
  description = "The alternative zone where the instance will be provisioned. a.k.a ( secondary availability zone )"
  type        = string
  default     = null
}

variable "redis_version" {
  description = "The version of Redis software."
  type        = string
  default     = "REDIS_6_X"
  
  validation {
    condition     = var.redis_version == "REDIS_3_2" || var.redis_version == "REDIS_4_0" || var.redis_version == "REDIS_5_0" || var.redis_version == "REDIS_6_X"
    error_message = "The value choosen is not in the list of ( REDIS_3_2, REDIS_4_0,  REDIS_5_0, REDIS_6_X)."
  }
}

variable "redis_configs" {
  description = "The Redis configuration parameters. See [more details](https://cloud.google.com/memorystore/docs/redis/reference/rest/v1/projects.locations.instances#Instance.FIELDS.redis_configs)"
  type        = map(any)
  default     = {}
}

variable "display_name" {
  description = "An arbitrary and optional user-provided name for the instance."
  type        = string
  default     = null
}

variable "reserved_ip_range" {
  description = "The CIDR range of internal addresses that are reserved for this instance."
  type        = string
  default     = null
}

## Difference Between DirectPeering and Private Service access is seen here (https://cloud.google.com/memorystore/docs/redis/networking)
variable "connect_mode" {
  description = "The connection mode of the Redis instance. Can be either DIRECT_PEERING or PRIVATE_SERVICE_ACCESS. The default connect mode if not provided is DIRECT_PEERING."
  type        = string
  default     = "DIRECT_PEERING"
  
  validation {
    condition     = var.connect_mode == "DIRECT_PEERING" || var.connect_mode == "PRIVATE_SERVICE_ACCESS"
    error_message = "The value choosen is not in the list of ( DIRECT_PEERING, PRIVATE_SERVICE_ACCESS)."
  }
  
}

variable "labels" {
  description = "The resource labels to represent user provided metadata."
  type        = map(string)
  default     = null
}

variable "default_labels" {
  type        = map(string)
  default     = {}
  description = "The key/value labels for the master instances."
}


##When you enable the AUTH feature on your Memorystore instance, incoming client connections must authenticate in order to connect.
##Generated authstring can be grabbed from outputs 
variable "auth_enabled" {
  description = "Indicates whether OSS Redis AUTH is enabled for the instance. If set to true AUTH is enabled on the instance."
  type        = bool
  default     = false
}

##By Default encryption mode is disabled. 
##If enabled, Certificate should be downloaded to your instance and run the commands to check ( ref below ) to connect to instance using tls certificate
## Download certificate from Redis Instance Page ---> Security
## Ref: https://stackoverflow.com/questions/71785724/gcp-memorystore-redis-protocol-error-got-x15-as-reply-type-byte
variable "transit_encryption_mode" {
  description = "The TLS mode of the Redis instance, If not provided, TLS is enabled for the instance."
  type        = string
  default     = "DISABLED"
  validation {
    condition     = var.transit_encryption_mode == "DISABLED" || var.transit_encryption_mode == "SERVER_AUTHENTICATION"
    error_message = "The value choosen is not in the list of ( DISABLED, SERVER_AUTHENTICATION)."
  }
}

variable "maintenance_policy" {
  description = "The maintenance policy for an instance."
  # type = object(any)
  type = object({
    day = string
    start_time = object({
      hours   = number
      minutes = number
      seconds = number
      nanos   = number
    })
  })
  default = {
    day = "SUNDAY"
    start_time = {
      hours   = 23
      minutes = 11
      seconds = 10
      nanos   = 10
    }
  }
}

variable "customer_managed_key" {
  description = "Default encryption key to apply to the Redis instance. Defaults to null (Google-managed)."
  type        = string
  default     = null
}
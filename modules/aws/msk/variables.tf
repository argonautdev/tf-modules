variable "default_tags" {
  description = "Default Tags"
  type        = map(string)
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "number_of_broker_nodes_per_zone" {
  type        = number
  default     = 1
  description = "The desired total number of broker nodes in the kafka cluster per zone."
  validation {
    condition = (
      var.number_of_broker_nodes_per_zone >= 1
    )
    error_message = "Number of broker nodes per zone must be greater than or equal to 1."
  }
}

variable "number_of_zones" {
  type        = number
  default     = 3
  description = "The desired total number of availability zones in the kafka cluster."
  validation {
    condition = (
      var.number_of_zones >= 1 &&
      var.number_of_zones <= 3
    )
    error_message = "Number of zones must be between 1 and 3, inclusive."
  }
}

variable "kafka_version" {
  type = string
  # this is the recommended version
  default     = "2.6.2"
  description = "The desired Kafka software version"
}

variable "broker_instance_type" {
  type        = string
  default     = "kafka.t3.small"
  description = "The instance type to use for the Kafka brokers"
}

variable "broker_volume_size" {
  type        = number
  default     = 1000
  description = "The size in GiB of the EBS volume for the data drive on each broker node"
}

variable "zone_id" {
  type        = string
  description = "Route53 DNS Zone ID for MSK broker hostnames"
  default     = null
}

# Intentionally not deprecated via security_group_inputs.tf since it cannot effectively be replaced via var.additional_security_group_rules.
# This is because the logic to create these rules exists within this module, and should not be passed in by the consumer
# of this module.
variable "allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "List of CIDR blocks to be allowed to connect to the cluster"
}

variable "client_broker" {
  type        = string
  default     = "TLS"
  description = "Encryption setting for data in transit between clients and brokers. Valid values: `TLS`, `TLS_PLAINTEXT`, and `PLAINTEXT`"
}

variable "encryption_in_cluster" {
  type        = bool
  default     = true
  description = "Whether data communication among broker nodes is encrypted"
}

variable "encryption_at_rest_kms_key_arn" {
  type        = string
  default     = ""
  description = "You may specify a KMS key short ID or ARN (it will always output an ARN) to use for encrypting your data at rest"
}

variable "enhanced_monitoring" {
  type        = string
  default     = "DEFAULT"
  description = "Specify the desired enhanced MSK CloudWatch monitoring level. Valid values: `DEFAULT`, `PER_BROKER`, and `PER_TOPIC_PER_BROKER`"
}

variable "certificate_authority_arns" {
  type        = list(string)
  default     = []
  description = "List of ACM Certificate Authority Amazon Resource Names (ARNs) to be used for TLS client authentication"
}

variable "client_sasl_scram_enabled" {
  type        = bool
  default     = false
  description = "Enables SCRAM client authentication via AWS Secrets Manager."
}

variable "client_sasl_scram_secret_association_arns" {
  type        = list(string)
  default     = []
  description = "List of AWS Secrets Manager secret ARNs for scram authentication."
}

variable "client_sasl_iam_enabled" {
  type        = bool
  default     = false
  description = "Enables client authentication via IAM policies"
}

variable "client_tls_auth_enabled" {
  type        = bool
  default     = false
  description = "Set `true` to enable the Client TLS Authentication"
}

variable "jmx_exporter_enabled" {
  type        = bool
  default     = false
  description = "Set `true` to enable the JMX Exporter"
}

variable "node_exporter_enabled" {
  type        = bool
  default     = false
  description = "Set `true` to enable the Node Exporter"
}

variable "cloudwatch_logs_enabled" {
  type        = bool
  default     = false
  description = "Indicates whether you want to enable or disable streaming broker logs to Cloudwatch Logs"
}

variable "cloudwatch_logs_log_group" {
  type        = string
  default     = null
  description = "Name of the Cloudwatch Log Group to deliver logs to"
}

variable "firehose_logs_enabled" {
  type        = bool
  default     = false
  description = "Indicates whether you want to enable or disable streaming broker logs to Kinesis Data Firehose"
}

variable "firehose_delivery_stream" {
  type        = string
  default     = ""
  description = "Name of the Kinesis Data Firehose delivery stream to deliver logs to"
}

variable "s3_logs_enabled" {
  type        = bool
  default     = false
  description = " Indicates whether you want to enable or disable streaming broker logs to S3"
}

variable "s3_logs_bucket" {
  type        = string
  default     = ""
  description = "Name of the S3 bucket to deliver logs to"
}

variable "s3_logs_prefix" {
  type        = string
  default     = ""
  description = "Prefix to append to the S3 folder name logs are delivered to"
}

variable "properties" {
  type        = map(string)
  default     = {}
  description = "Contents of the server.properties file. Supported properties are documented in the [MSK Developer Guide](https://docs.aws.amazon.com/msk/latest/developerguide/msk-configuration-properties.html)"
}

variable "storage_autoscaling_target_value" {
  type        = number
  default     = 60
  description = "Percentage of storage used to trigger autoscaled storage increase"
}

variable "storage_autoscaling_max_capacity" {
  type        = number
  default     = null
  description = "Maximum size the autoscaling policy can scale storage. Defaults to `broker_volume_size`"
}

variable "storage_autoscaling_disable_scale_in" {
  type        = bool
  default     = false
  description = "If the value is true, scale in is disabled and the target tracking policy won't remove capacity from the scalable resource."
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

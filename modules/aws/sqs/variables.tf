variable "create" {
  description = "Whether to create SQS queue"
  type        = bool
  default     = true
}

variable "name" {
  description = "This is the human-readable name of the queue. If omitted, Terraform will assign a random name."
  type        = string
  default     = null
}

variable "aws_region" {
  default     = "us-east-1"
  description = "Region"
}

# variable "name_prefix" {
#   description = "A unique name beginning with the specified prefix."
#   type        = string
#   default     = null
# }

variable "visibility_timeout_seconds" {
  description = "The visibility timeout for the queue. An integer from 0 to 43200 (12 hours)"
  type        = number
  default     = 30
}

variable "message_retention_seconds" {
  description = "The number of seconds Amazon SQS retains a message. Integer representing seconds, from 60 (1 minute) to 1209600 (14 days). The default for this attribute is 345600 (4 days)"
  type        = number
  default     = 345600
}

variable "max_message_size" {
  description = "The limit of how many bytes a message can contain before Amazon SQS rejects it. An integer from 1024 bytes (1 KiB) up to 262144 bytes (256 KiB)"
  type        = number
  default     = 262144
}

variable "delay_seconds" {
  description = "The time in seconds that the delivery of all messages in the queue will be delayed. An integer from 0 to 900 (15 minutes)"
  type        = number
  default     = 0
}

variable "receive_wait_time_seconds" {
  description = "The time for which a ReceiveMessage call will wait for a message to arrive (long polling) before returning. An integer from 0 to 20 (seconds)"
  type        = number
  default     = 0
}

variable "policy" {
  description = "The JSON policy for the SQS queue"
  type        = string
  default     = ""
}

variable "redrive_policy" {
  description = "Arn of the existing queue to receive undeliverable messages."
  type        = object({
    deadLetterTargetArn = string
  })
  default     = {
    deadLetterTargetArn = null
  }
}

variable "redrive_allow_policy" {
  description = "Arn of the source queues can use this queue as the dead-letter queue. "
  type        = object({
    sourceQueueArns   = string
  })
  default     = {
    sourceQueueArns = null
  }
}

variable "fifo_queue" {
  description = "Boolean designating a FIFO queue"
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Enables content-based deduplication for FIFO queues"
  type        = bool
  default     = false
}

variable "kms_master_key_id" {
  description = "The ID of an AWS-managed customer master key (CMK) for Amazon SQS or a custom CMK"
  type        = string
  default     = null
}

variable "sqs_managed_sse_enabled" {
  description = "Boolean to enable server-side encryption (SSE) of message content with SQS-owned encryption keys"
  type        = bool
  default     = true
}

variable "default_tags" {
  description = "Default Tags for sqs"
  type        = map(string)
  default = {}
}
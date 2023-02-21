module "sqs_queue" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "3.4.0"

  create = var.create
  name = var.name
  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds = var.message_retention_seconds
  max_message_size = var.max_message_size
  delay_seconds = var.delay_seconds
  receive_wait_time_seconds = var.receive_wait_time_seconds
  redrive_policy = var.redrive_policy.deadLetterTargetArn != null ? jsonencode({
    maxReceiveCount     = 4
    deadLetterTargetArn = var.redrive_policy.deadLetterTargetArn
  }) : ""
  redrive_allow_policy = var.redrive_allow_policy.sourceQueueArns != null ? jsonencode({
    redrivePermission = "byQueue"
    sourceQueueArns = [var.redrive_allow_policy.sourceQueueArns]
  }) : ""
  fifo_queue = var.fifo_queue
  sqs_managed_sse_enabled = var.sqs_managed_sse_enabled
  kms_master_key_id = var.kms_master_key_id
}
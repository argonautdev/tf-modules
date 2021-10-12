provider "aws" {
  region = var.region
}
module "elasticsearch" {
  source  = "cloudposse/elasticsearch/aws"
  version = "0.33.1"
 
  enabled = true
  
  security_groups                = [var.vpc.default_security_group_id]
  vpc_enabled                    = var.is_public == true ? false : true
  // vpc_enabled                    = var.vpc_enabled
  vpc_id                         = var.vpc.id
  subnet_ids                     = var.is_public == true ? slice(var.vpc.public_subnets, 0, var.az_count) : slice(var.vpc.private_subnets, 0, var.az_count)

  zone_awareness_enabled         = var.zone_awareness_enabled
  elasticsearch_version          = var.elasticsearch_version

  instance_type                  = var.instance_type
  instance_count                 = var.instance_count_per_az * var.az_count
  ebs_volume_size                = var.ebs_volume_size
  encrypt_at_rest_enabled        = var.encrypt_at_rest_enabled
  
  dedicated_master_enabled       = var.dedicated_master_enabled
  dedicated_master_count = var.dedicated_master_count
  dedicated_master_type          = var.dedicated_master_type

  create_iam_service_linked_role = var.create_iam_service_linked_role

  kibana_subdomain_name          = var.kibana_subdomain_name
  dns_zone_id                    = var.dns_zone_id
  kibana_hostname_enabled        = var.kibana_hostname_enabled
  domain_hostname_enabled        = var.domain_hostname_enabled
  elasticsearch_subdomain_name   = var.elasticsearch_subdomain_name

  custom_endpoint_enabled         = var.custom_endpoint_enabled
  custom_endpoint                 = var.custom_endpoint
  custom_endpoint_certificate_arn = var.custom_endpoint_certificate_arn

  advanced_security_options_enabled = var.advanced_security_options_enabled
  advanced_security_options_internal_user_database_enabled = var.advanced_security_options_internal_user_database_enabled
  advanced_security_options_master_user_name = var.advanced_security_options_master_user_name
  advanced_security_options_master_user_password = var.advanced_security_options_master_user_password

  node_to_node_encryption_enabled = var.node_to_node_encryption_enabled
  domain_endpoint_options_enforce_https = var.domain_endpoint_options_enforce_https

  log_publishing_index_enabled = var.log_publishing_index_enabled
  log_publishing_search_enabled = var.log_publishing_search_enabled
  log_publishing_audit_enabled = var.log_publishing_audit_enabled
  log_publishing_application_enabled = var.log_publishing_application_enabled
  log_publishing_index_cloudwatch_log_group_arn = var.log_publishing_index_cloudwatch_log_group_arn
  log_publishing_search_cloudwatch_log_group_arn = var.log_publishing_search_cloudwatch_log_group_arn
  log_publishing_audit_cloudwatch_log_group_arn = var.log_publishing_audit_cloudwatch_log_group_arn
  log_publishing_application_cloudwatch_log_group_arn = var.log_publishing_application_cloudwatch_log_group_arn

  automated_snapshot_start_hour = var.automated_snapshot_start_hour

  // allowed_cidr_blocks = var.allowed_cidr_blocks
  allowed_cidr_blocks = var.is_public == true ? ["0.0.0.0/0"] : var.allowed_cidr_blocks

  tags = var.tags

  advanced_options = var.advanced_options

  cognito_authentication_enabled = var.cognito_authentication_enabled
  cognito_identity_pool_id = var.cognito_identity_pool_id
  cognito_user_pool_id = var.cognito_user_pool_id
  cognito_iam_role_arn = var.cognito_iam_role_arn


  context = module.this.context
}
# Use this data source to get the access to the effective Account ID in which
# Terraform is working.
data "aws_caller_identity" "current" {}

# To obtain the name of the AWS region configured on the provider
data "aws_region" "current" {}

module "aws_es" {

  source = "lgallard/elasticsearch/aws"
  version = "0.12.2"

  domain_name           = var.es_domain_name
  elasticsearch_version = var.es_version

  cluster_config = {
    dedicated_master_enabled = false
    instance_count           = 2
    instance_type            = "t3.small.elasticsearch"
    zone_awareness_enabled   = true
    availability_zone_count  = 2
  }

  ebs_options = {
    ebs_enabled = true
    volume_size = 10
  }

  encrypt_at_rest = {
    enabled    = true
    // kms_key_id = "arn:aws:kms:us-east-1:123456789101:key/cccc103b-4ba3-5993-6fc7-b7e538b25fd8"
  }

  vpc_options = {
    subnet_ids         = slice(var.vpc.subnets, 0, 2)
    security_group_ids = [var.vpc.default_security_group_id]
  }

  node_to_node_encryption_enabled                = true
  snapshot_options_automated_snapshot_start_hour = 03

  access_policies = templatefile("${path.module}/access_policies.tpl", {
    region      = data.aws_region.current.name,
    account     = data.aws_caller_identity.current.account_id,
    domain_name = var.es_domain_name
  })

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = true
    }

  timeouts_update = "90m"

}
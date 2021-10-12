
module "aws_es" {
  source  = "lgallard/elasticsearch/aws"
  version = "0.12.2"

  domain_name                                    = var.domain_name
  elasticsearch_version                          = var.elasticsearch_version
  cluster_config                                 = var.cluster_config
  domain_endpoint_options                        = var.domain_endpoint_options
  ebs_options                                    = var.ebs_options
  encrypt_at_rest                                = var.encrypt_at_rest
  vpc_options                                    = var.vpc_options
  node_to_node_encryption_enabled                = var.node_to_node_encryption_enabled
  snapshot_options_automated_snapshot_start_hour = var.snapshot_options_automated_snapshot_start_hour
  access_policies                                = var.access_policies
  advanced_options                               = var.advanced_options
  advanced_security_options                      = var.advanced_security_options
  create_service_link_role                       = var.create_service_link_role
  timeouts_update                                = var.timeouts_update
}
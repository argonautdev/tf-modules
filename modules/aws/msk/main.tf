module "msk" {
  source  = "cloudposse/msk-apache-kafka-cluster/aws"
  version = "0.8.2"

  zone_id                = var.zone_id
  security_groups        = [var.vpc.default_security_group_id]
  vpc_id                 = module.vpc.vpc_id
  subnet_ids             = var.vpc.private_subnet_ids
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.number_of_broker_nodes
  broker_instance_type   = var.broker_instance_type

  context = module.this.context
}
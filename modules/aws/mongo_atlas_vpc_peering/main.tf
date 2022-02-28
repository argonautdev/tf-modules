data "aws_caller_identity" "account" {}

data "aws_vpc" "primary" {
  id = var.vpc.vpc_id
}

data "mongodbatlas_project" "aws_atlas" {
  project_id = var.atlas_project_id
}

data "mongodbatlas_network_container" "atlas_container" {
  container_id = var.atlas_container_id
  project_id   = data.mongodbatlas_project.aws_atlas.id
}

resource "mongodbatlas_network_peering" "aws-atlas" {
  accepter_region_name   = var.aws_region
  project_id             = data.mongodbatlas_project.aws_atlas.id
  container_id           = var.atlas_container_id
  provider_name          = "AWS"
  route_table_cidr_block = data.aws_vpc.primary.cidr_block
  vpc_id                 = data.aws_vpc.primary.id
  aws_account_id         = data.aws_caller_identity.account.account_id
}

resource "aws_route" "peeraccess" {
  route_table_id            = data.aws_vpc.primary.main_route_table_id
  destination_cidr_block    = var.atlas_vpc_cidr
  vpc_peering_connection_id = mongodbatlas_network_peering.aws-atlas.connection_id
  depends_on                = [aws_vpc_peering_connection_accepter.peer]
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = mongodbatlas_network_peering.aws-atlas.connection_id
  auto_accept               = true
}

data "aws_caller_identity" "account" {}

data "aws_vpc" "primary" {
  id = var.vpc.vpc_id
}

data "mongodbatlas_project" "aws_atlas" {
  project_id = var.atlas_project_id
}

##Container is Just VPC
resource "mongodbatlas_network_container" "atlas_container" {
  atlas_cidr_block = var.atlas_vpc_cidr
  project_id       = data.mongodbatlas_project.aws_atlas.id
  provider_name    = "AWS"
  region_name      = var.atlas_region
}

data "mongodbatlas_network_container" "atlas_container" {
  container_id = mongodbatlas_network_container.atlas_container.container_id
  project_id   = data.mongodbatlas_project.aws_atlas.id
}

resource "mongodbatlas_network_peering" "aws-atlas" {
  accepter_region_name   = var.aws_region
  project_id             = data.mongodbatlas_project.aws_atlas.id
  container_id           = mongodbatlas_network_container.atlas_container.container_id
  provider_name          = "AWS"
  route_table_cidr_block = data.aws_vpc.primary.cidr_block
  vpc_id                 = data.aws_vpc.primary.id
  aws_account_id         = data.aws_caller_identity.account.account_id
}

data "aws_route_tables" "private_rt_filters" {
  vpc_id = var.vpc.vpc_id
  filter  {
    name = "tag:Name"
    values = [
       "${var.vpc.name}-private"
    ]
  }
}

data "aws_route_tables" "public_rt_filters" {
  vpc_id = var.vpc.vpc_id
  filter  {
    name = "tag:Name"
    values = [
       "${var.vpc.name}-public"
    ]
  }
}

resource "aws_route" "peeraccess" {
  route_table_id            = data.aws_vpc.primary.main_route_table_id
  destination_cidr_block    = var.atlas_vpc_cidr
  vpc_peering_connection_id = mongodbatlas_network_peering.aws-atlas.connection_id
  depends_on                = [aws_vpc_peering_connection_accepter.peer]
}

resource "aws_route" "peerprivatertaccess" {
  count                     = length(data.aws_route_tables.private_rt_filters.ids)
  route_table_id            = tolist(data.aws_route_tables.private_rt_filters.ids)[count.index]
  destination_cidr_block    = var.atlas_vpc_cidr
  vpc_peering_connection_id = mongodbatlas_network_peering.aws-atlas.connection_id
  depends_on                = [aws_vpc_peering_connection_accepter.peer]
}

resource "aws_route" "peerpublicrtaccess" {
  count                     = length(data.aws_route_tables.public_rt_filters.ids)
  route_table_id            = tolist(data.aws_route_tables.public_rt_filters.ids)[count.index]
  destination_cidr_block    = var.atlas_vpc_cidr
  vpc_peering_connection_id = mongodbatlas_network_peering.aws-atlas.connection_id
  depends_on                = [aws_vpc_peering_connection_accepter.peer]
}

##IP Access List entry resource. The access list grants access from IPs, CIDRs or AWS Security Groups (if VPC Peering is enabled) to clusters within the Project.
resource "mongodbatlas_project_ip_access_list" "atlas-ip-access-list-1" {
  project_id = var.atlas_project_id
  cidr_block = data.aws_vpc.primary.cidr_block
  comment    = "CIDR block of the VPC"
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = mongodbatlas_network_peering.aws-atlas.connection_id
  auto_accept               = true
}

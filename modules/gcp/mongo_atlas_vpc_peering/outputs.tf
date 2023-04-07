output "atlas_vpcpeer_project_id" {
   description = "MongoAtlas GCP ProjectID where the network container (i.e VPC ) deployed"
   value = mongodbatlas_network_peering.gcp-atlas.atlas_gcp_project_id
}

output "atlas_vpcpeer_network_name" {
   description = "MongoAtlas GCP Network name"
   value = mongodbatlas_network_peering.gcp-atlas.atlas_vpc_name
}
include {
  path = find_in_parent_folders()
}

terraform {
  # the below config is an example of what the config should like
  source = "github.com/argonautdev/tf-modules.git//modules/gcp/mongo_atlas_vpc_peering?ref={{.RefVersion}}"
}

dependency "{{.Spec.vpc_id}}" {
  config_path = "../vpc_{{.Spec.vpc_id}}"
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  vpc_network_name = dependency.{{ .Spec.vpc_id }}.outputs.network_name

  atlas_public_key="{{.Spec.atlas_public_key}}"
  atlas_private_key="{{.Spec.atlas_private_key}}"
  atlas_project_id="{{.Spec.atlas_project_id}}"
  
  default_labels = {
    "argonaut-id"        = "{{.Spec.id}}"
    "argonaut-name"        = "{{.Spec.name}}"
    "argonaut-type"        = "MongoDB-Atlas-VPC-Peering"
    "argonaut-manager"     = "argonautdev"
    "argonaut-environment" = "{{.Environment.Name}}"
  }
  subnetwork_cidr_block = "{{.Spec.subnetwork_cidr_block}}"
}

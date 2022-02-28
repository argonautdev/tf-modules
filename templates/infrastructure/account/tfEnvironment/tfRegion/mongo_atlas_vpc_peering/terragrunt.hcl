include {
  path = find_in_parent_folders()
}

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  env    = local.environment_vars.locals.environment
  region = local.region_vars.locals.aws_region
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  # the below config is an example of what the config should like
  source = "github.com/argonautdev/tf-modules.git//modules/aws/mongo_atlas_vpc_peering?ref={{.RefVersion}}"
}

dependency "vpc" {
  config_path  = "../vpc"
  mock_outputs = {
    vpc_id = "temporary-dummy-id",
  }
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  aws_region = "${local.region}"

  vpc = {
    name   = "${local.env}"
    vpc_id = dependency.vpc.outputs.vpc_id
  }

  atlas_public_key   = "{{.Spec.atlas_public_key}}"
  atlas_private_key  = "{{.Spec.atlas_private_key}}"
  atlas_region       = "{{.Spec.atlas_region}}"
  atlas_org_id       = "{{.Spec.atlas_org_id}}"
  atlas_vpc_cidr     = "{{.Spec.atlas_vpc_cidr}}"
  atlas_project_name = "{{.Spec.atlas_project_name}}"
  atlas_container_id = "{{.Spec.atlas_container_id}}"

  default_tags = {
    "argonaut.dev/name"             = "{{.Spec.name}}"
    "argonaut.dev/manager"          = "argonaut.dev"
    "argonaut.dev/type"             = "MongoDB-Atlas-VPC-Peering"
    "argonaut.dev/env/${local.env}" = "true"
  }
}

locals {
  # Automatically load environment-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract out common variables for reuse
  map_users = local.account_vars.locals.map_users
  map_accounts = local.account_vars.locals.map_accounts

  env = local.environment_vars.locals.environment

  region = local.region_vars.locals.aws_region
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
# terraform {
#   source = "git::git@github.com:gruntwork-io/terragrunt-infrastructure-modules-example.git//mysql?ref=v0.4.0"
# }

terraform {

  # the below config is an example of what the config should like
  source = "git::git@github.com:argonautdev/tf-modules.git//modules/aws/eks?ref={{.RefVersion}}"

  # source = "/Users/akash.patro/Code/argonaut/tf-modules//modules/aws/eks"
}

include {
  path = find_in_parent_folders("backend.hcl")
}

dependency "vpc" {
  config_path = "../vpc"
   mock_outputs = {
    vpc_id = "temporary-dummy-id",
    private_subnets = ["temporary-dummy-subnet-1", "temporary-dummy-subnet-2"]
  }
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  default_tags = {
    "argonaut.dev/name" = "{{.Cluster.Name}}"
    "argonaut.dev/manager" = "argonaut.dev"
    "argonaut.dev/type" = "EKS Cluster"
    "argonaut.dev/env/${local.env}" = "true"
  }

  env = "${local.env}"
  vpc = {
    name    = "${local.env}"
    vpc_id      = dependency.vpc.outputs.vpc_id
    private_subnets = dependency.vpc.outputs.private_subnets
  }

  cluster = {
    name = "{{.Cluster.Name}}"
  }

  node_group = {
    name = "{{.NodeGroup.Name}}"
    desired_capacity = {{.NodeGroup.NumberOfInstance}}
    max_capacity = {{.NodeGroup.NumberOfInstanceMax}}
    min_capacity = {{.NodeGroup.NumberOfInstanceMin}}
    disk_size = {{.NodeGroup.DiskSize}}
    instance_type = "{{.NodeGroup.InstanceType}}"
    spot = {{.NodeGroup.Spot}}
  }

  # account level spec kept at account level
  map_users = local.map_users
  map_accounts = local.map_accounts

  aws_region = "${local.region}"
}


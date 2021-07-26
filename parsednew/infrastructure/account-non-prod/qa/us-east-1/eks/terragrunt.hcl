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
  # source = "git::git@github.com:gruntwork-io/tf-modules.git//modules/aws/env_cluster_nodegroup?ref=v0.4.0"

  # source = "git::git@github.com:argonautdev/tf-modules.git//modules/aws/eks?ref=v0.3.0"
  source = "../../../../../..//modules/aws/eks"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders("backend.hcl")
}

dependency "vpc" {
  config_path = "../vpc"
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  default_tags = {
    "argonaut.dev/name" = "ligma"
    "argonaut.dev/manager" = "argonaut.dev"
    "argonaut.dev/type" = "EKS Cluster"
    "argonaut.dev/env/${local.env}" = "true"
  }

  vpc = {
    name    = "${local.env}"
    id      = dependency.vpc.outputs.vpc_id
    subnets = dependency.vpc.outputs.private_subnets
  }

  cluster = {
    name = "ligma"
  }

  node_group = {
    name = "ligma"
    desired_capacity = 3
    max_capacity = 3
    min_capacity = 1
    disk_size = 20
    instance_type = "t3.medium"
    spot = true
  }

  # account level spec kept at account level
  map_users = local.map_users
  map_accounts = local.map_accounts

  region = local.region
}

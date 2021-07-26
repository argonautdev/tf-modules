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
  source = "git::git@github.com:gruntwork-io/tf-modules.git//modules/aws/rds?ref={{.RefVersion}}"

  # source = "/Users/akash.patro/Code/argonaut/tf-modules//modules/aws/rds"
}

dependency "vpc" {
  config_path = "../vpc"
   mock_outputs = {
    vpc_id = "temporary-dummy-id",
    public_subnets = ["temporary-dummy-subnet-1", "temporary-dummy-subnet-2"],
    vpc_cidr_block = "10.0.0.0/8"
  }
}


# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  default_tags = {
    "argonaut.dev/name"        = "{{ .RDS.Name }}"
    "argonaut.dev/type"        = "RDS"
    "argonaut.dev/manager"     = "argonaut.dev"
    "argonaut.dev/env/${local.env}" = "true"
  }
  aws_region = "${local.region}"

  visibility = "{{ .RDS.Visibility }}"

  identifier     = "{{ .RDS.Identifier }}"
  name           = "{{ .RDS.Name }}"
  engine         = "{{ .RDS.Engine }}"
  engine_version = "{{ .RDS.EngineVersion }}"

  storage        = {{ .RDS.Storage }}
  instance_class = "{{ .RDS.InstanceClass }}"
  username       = "{{ .RDS.Username }}"
  password       = "{{ .RDS.Password }}"
  family       = "{{ .RDS.Family }}"
  db_subnet = "{{ .RDS.Name }}-db-subnet"

  vpc = {
    name    = "${local.env}"
    vpc_id      = dependency.vpc.outputs.vpc_id
    public_subnets = dependency.vpc.outputs.public_subnets
    vpc_cidr_block = dependency.vpc.outputs.vpc_cidr_block
  }

}
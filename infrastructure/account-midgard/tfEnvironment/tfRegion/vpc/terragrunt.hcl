locals {
  # Automatically load environment-level variables
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract out common variables for reuse
  map_users    = local.account_vars.locals.map_users
  map_accounts = local.account_vars.locals.map_accounts

  env = local.environment_vars.locals.environment

  region = local.region_vars.locals.aws_region
  
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
# terraform {
#   source = "git::git@github.com:gruntwork-io/terragrunt-infrastructure-modules-example.git//mysql?ref=v0.4.0"
# }
# include {
#   path = find_in_parent_folders("backend.hcl")
# }
remote_state {
  backend = "pg" 
  config = {
    conn_str = "postgres://{{.BackendData.Username}}:{{.BackendData.Password}}@{{.BackendData.Host}}/{{.Organization.Name}}"
    schema_name = "tf_{{.Environment.Name}}_vpc_{{ .Environment.Name }}"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

terraform {

  # the below config is an example of what the config should like
  # source = "git::git@github.com:gruntwork-io/tf-modules.git//modules/aws/env_cluster_nodegroup?ref=v0.4.0"
#   source = "git::git@github.com:argonautdev/tf-modules.git//modules/aws/vpc?ref={{.RefVersion}}"
  # source = "github.com/argonautdev/tf-modules.git//modules/aws/vpc?ref={{.RefVersion}}"

  source = "/Users/akash.patro/Code/argonaut/tf-modules//modules/aws/vpc"
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  default_tags = {
    "argonaut.dev/name"        = "${local.env}"
    "argonaut.dev/type"        = "VPC"
    "argonaut.dev/manager"     = "argonaut.dev"
    "argonaut.dev/environment" = "${local.env}"
  }
  aws_region                 = "${local.region}"
  # vpc name should be same as env name
  name                       = "${local.env}"
  cidr_block                 = "10.0.0.0/16" 
  enable_vpn_gateway         = true
  public_subnet_count        = 2
  private_subnet_count       = 2
  public_subnet_cidr_blocks  = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  private_subnet_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  enable_dns_hostnames       = true
  enable_nat_gateway         = true
  single_nat_gateway         = true
}

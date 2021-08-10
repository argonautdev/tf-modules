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
  # source = "github.com/argonautdev/tf-modules.git//modules/aws/eks?ref={{.RefVersion}}"

  source = "/Users/akash.patro/Code/argonaut/tf-modules//modules/aws/eksAutoScaler"
}

# include {
#   path = find_in_parent_folders("backend.hcl")
# }
remote_state {
  backend = "pg" 
  config = {
    conn_str = "postgres://{{.BackendData.Username}}:{{.BackendData.Password}}@{{.BackendData.Host}}/{{.Organization.Name}}"
    schema_name = "tf_{{.Environment.Name}}_eksAutoScaler_{{ .Cluster.Name }}"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

dependency "eks" {
  config_path = "../eks"
   mock_outputs = {
    cluster_id = "1234"
    cluster_endpoint = "abcd.com"
    certificate_authority_data = "temp_cert_data"
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

  eks = {
    id = dependency.eks.outputs.cluster_id
    endpoint = dependency.eks.outputs.cluster_endpoint
    certificate_authority_data = dependency.eks.outputs.certificate_authority_data
  }

  role_arn = dependency.eks.outputs.role_arn
  service_account_name = dependency.eks.outputs.service_account_name

  # account level spec kept at account level
  map_users = local.map_users
  map_accounts = local.map_accounts

  aws_region = "${local.region}"

  aws_account_id = "054565121117"
}

